from flask import Flask, render_template, url_for, copy_current_request_context, request
from random import random
from time import sleep
import numpy as np
import io
from PIL import Image
import base64

device_count = 0

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
app.config['DEBUG'] = False


@app.route('/')
def index():
    return "hello"
    
@app.route("/test", methods=["POST"])
def process_request():
    file = request.form.get('file')
    name = request.form.get('name')
    count = request.form.get('count')
    with open("imageToSave.jpg", "wb") as fh:
        fh.write(base64.b64decode(file))

    #image = Image.open(io.BytesIO(bytess))
    return "bla"
    
if __name__ == "__main__":
    app.run()
    



