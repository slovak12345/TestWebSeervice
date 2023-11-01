"""CLI interface for project_name project.

Be creative! do whatever you want!

- Install click or typer and create a CLI app
- Use builtin argparse
- Start a web application
- Import things from your .base module
"""

from aiohttp import web
import json
import threading
from currentStatusWorker import CurrentStatusWorker
from shutdownWorker import ShutdownWorker
from workerStatusWorker import WorkerStatusWorker

async def handle(request):
    name = request.match_info.get('name', "Anonymous")
    text = "Hello, " + name
    return web.Response(text=text)

async def wshandle(request):
    ws = web.WebSocketResponse()
    await ws.prepare(request)

    async for msg in ws:
        if msg.type == web.WSMsgType.text:
            await ws.send_str("Hello, {}".format(msg.data))
        elif msg.type == web.WSMsgType.binary:
            await ws.send_bytes(msg.data)
        elif msg.type == web.WSMsgType.close:
            break

    return ws

current_status_data = {}
working_status_data = {}
shutdown_work_data = {}
current_config_data = {}

async def current_status_handle(request):
    data = current_status_data
    result = json.dumps(data) 
    return web.Response(text=result)

async def working_status_handle(request):
    data = working_status_data
    result = json.dumps(data) 
    return web.Response(text=result)

async def shutdown_work_handle(request):
    data = shutdown_work_data
    result = json.dumps(data) 
    return web.Response(text=result)

async def current_config_handle(request):
    data = current_config_data
    result = json.dumps(data) 
    return web.Response(text=result)

app = web.Application()
app.add_routes([web.get('/', handle),
                web.get('/echo', wshandle)])

app.add_routes([web.get('/', handle),
                web.get('/current-status', current_status_handle),
                web.get('/working-status', working_status_handle),
                web.get('/shutdown-work', shutdown_work_handle),
                web.get('/current-config', current_config_handle)])

def main():  # pragma: no cover
    currentStatusWorker=CurrentStatusWorker()
    shutdownWorker=ShutdownWorker()
    workerStatusWorker=WorkerStatusWorker()

    currentStatusWorker.join()
    shutdownWorker.join()
    workerStatusWorker.join()
    """
    The main function executes on commands:
    `python -m project_name` and `$ project_name `.

    This is your program's entry point.

    You can change this function to do whatever you want.
    Examples:
        * Run a test suite
        * Run a server
        * Do some other stuff
        * Run a command line application (Click, Typer, ArgParse)
        * List all available tasks
        * Run an application (Flask, FastAPI, Django, etc.)
    """
    web.run_app(app)
