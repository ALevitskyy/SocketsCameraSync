import UIKit
import AVFoundation

class ViewController: UIViewController {

    // MARK: - Properties
    
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    fileprivate var videoSession: AVCaptureSession!
    fileprivate var cameraDevice: AVCaptureDevice!
    fileprivate var frameCount: Int!
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.prepareCamera()
        self.startSession()
    }
}


// MARK: - Prepare&Start&Stop camera




extension ViewController {
    
    
    func startSession() {
        if let videoSession = videoSession {
            if !videoSession.isRunning {
                videoSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if let videoSession = videoSession {
            if videoSession.isRunning {
                videoSession.stopRunning()
            }
        }
    }
    
    fileprivate func prepareCamera() {
        self.videoSession = AVCaptureSession()
        self.videoSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        self.previewLayer = AVCaptureVideoPreviewLayer(session: videoSession)
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.frameCount = 0
        
        
        if let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] {
            for device in devices {
                if device.hasMediaType(AVMediaType.video) {
                    cameraDevice = device
                    
                    if cameraDevice != nil  {
                        do {
                            let input = try AVCaptureDeviceInput(device: cameraDevice)
                            
                            
                            if videoSession.canAddInput(input) {
                                videoSession.addInput(input)
                                print("added input")
                            }
                            
                            if let previewLayer = self.previewLayer {
                                if previewLayer.connection!.isVideoMirroringSupported {
                                    previewLayer.connection!.automaticallyAdjustsVideoMirroring = false
                                    previewLayer.connection!.isVideoMirrored = false
                                }
                                
                                previewLayer.frame = self.view.bounds
                                view.layer.addSublayer(previewLayer)
                                //view.layer = previewLayer
                                //view.wantsLayer = true
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
            if videoSession.canAddOutput(videoOutput) {
                print("i made it to here")
                videoSession.addOutput(videoOutput)
            }
        }
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
//func jpegDataFrom(image:NSImage) -> Data {
//    let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
//    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
//    let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
//    return jpegData
//}
func convertImage(cmage:CIImage) -> UIImage
{
    let context:CIContext = CIContext.init(options: nil)
    let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
    let image:UIImage = UIImage.init(cgImage: cgImage)
    return image
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        let imageBuffer: CVPixelBuffer = sampleBuffer.imageBuffer!
        let ciImage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let uiImage : UIImage = convertImage(cmage: ciImage)
        //let rep = NSCIImageRep(ciImage: ciImage)
        //let nsImage = NSImage(size: rep.size)
        //nsImage.addRepresentation(rep)
        //let jpegData = jpegDataFrom(image: nsImage)
        let jpegData = uiImage.jpegData(compressionQuality: 1.0)
        //print(jpegData)

        let base64String = jpegData!.base64EncodedString(options: .lineLength64Characters)
        sendData(count: frameCount, data: base64String)
        frameCount = frameCount + 1
        //sendData(count: frameCount, data: "hello")
        }
    }

