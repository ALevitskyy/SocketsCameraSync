import eventlet
eventlet.monkey_patch()
from flask_socketio import SocketIO, emit
from flask import Flask, render_template, url_for, copy_current_request_context
from random import random
from time import sleep
import base64

device_count = 0

__author__ = 'slynn'

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
app.config['DEBUG'] = False

#turn the flask app into a socketio app
socketio = SocketIO(app,cors_allowed_origins="*")

def send_message_to_admin(message):
    socketio.emit(
       'message', 
        {'message': message}, 
        broadcast = True,
        namespace = "/admin")

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/camera')
def camera():
    return render_template('camera.html')

@app.route('/start_recording', methods=["POST"])
def start_recording():
    print("recording started")
    socketio.emit(
       'start_recording', 
        broadcast = True,
        namespace = "/test")
    send_message_to_admin("recording started")
    return ""

@app.route('/end_recording', methods=["POST"])
def end_recording():
    print("recording ended")
    socketio.emit(
        'end_recording', 
        broadcast = True,
        namespace= "/test")
    send_message_to_admin("recording ended")
    return ""

@socketio.on("files", namespace='/test')
def save_files(json):
    video_binary = json["video"]["dataURL"].split(",")[1] # the way output string structured
    filename = json["name"]+".webm"
    with open(filename, "wb") as file:
        file.write(base64.b64decode(video_binary))
        

    

@socketio.on('connect', namespace='/test')
def test_connect():
    global device_count
    name = "camera "+str(device_count)
    emit("name_assign", {"name":name})
    send_message_to_admin("camera " + name + " has connected")
    device_count += 1
    pass

@socketio.on('connect', namespace='/admin')
def admin_connect():
    print("Admin Connected")
    pass

@socketio.on('disconnect', namespace='/test')
def test_disconnect():
    print('Client disconnected')
    pass

@socketio.on('disconnect', namespace='/admin')
def admin_disconnect():
    print('Admin disconnected')
    pass


if __name__ == '__main__':
    socketio.run(app)

