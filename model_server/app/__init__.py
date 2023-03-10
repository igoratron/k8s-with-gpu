import os
import torch

from flask import Flask

def create_app():
    app = Flask(__name__)

    @app.route('/ping')
    def hello():
        use_cuda = torch.cuda.is_available()
        return {
            'is_cuda_enabled_service': use_cuda
        }

    return app
