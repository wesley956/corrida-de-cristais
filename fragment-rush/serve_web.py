import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

class Handler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()

    def guess_type(self, path):
        if path.endswith(".wasm"):
            return "application/wasm"
        if path.endswith(".pck"):
            return "application/octet-stream"
        return super().guess_type(path)

os.chdir(os.path.join(os.path.dirname(__file__), "build", "web"))
server = ThreadingHTTPServer(("0.0.0.0", 5000), Handler)
print("Fragment Rush rodando em http://0.0.0.0:5000")
server.serve_forever()
