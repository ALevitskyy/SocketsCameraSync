//
//  ViewController.swift
//  macOS Camera
//
//  Created by Mihail Șalari. on 4/24/17.
//  Copyright © 2017 Mihail Șalari. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

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

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
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
                                    previewLayer.connection!.isVideoMirrored = true
                                }
                                
                                previewLayer.frame = self.view.bounds
                                view.layer = previewLayer
                                view.wantsLayer = true
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
func jpegDataFrom(image:NSImage) -> Data {
    let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
    return jpegData
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        //let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let imageBuffer: CVPixelBuffer = sampleBuffer.imageBuffer!
        let ciImage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let rep = NSCIImageRep(ciImage: ciImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        let jpegData = jpegDataFrom(image: nsImage)
        print(jpegData)
        //let fileURL = try! FileManager.default
        //.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        //.appendingPathComponent("test.jpg")
        //try! jpegData.write(to: fileURL, options: .atomic)
        //let test_data = NSData(data: jpegData)
        //let dataString: String? = "\(test_data)"
        let base64String = jpegData.base64EncodedString(options: .lineLength64Characters)
        sendData(count: frameCount, data: base64String)
        //sendData(count: frameCount, data: "hello")
        frameCount = frameCount + 1
        
        //print(CMSampleBufferGetTotalSampleSize(sampleBuffer))
        }
    }
