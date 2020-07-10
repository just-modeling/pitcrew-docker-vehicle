"""
Return config on servers to start for theia
 
See https://jupyter-server-proxy.readthedocs.io/en/latest/server-process.html
for more information.
"""
import os
import shutil
 
def setup_openrefine():
    # Make sure theia is in $PATH
    def _openrefine_command(port):
        REFINEVERSION = os.getenv('REFINEVERSION','3.0')
        return ['/home/jovyan/.openrefine/openrefine-{REFINEVERSION}/refine'.format(REFINEVERSION=REFINEVERSION), '-i','0.0.0.0','-p', str(port),'-d','/home/jovyan/work','-m','2500M']
 
    return {
        'command': _openrefine_command,
#         'timeout': 120,
#         'absolute_url': True,
        'launcher_entry': {
            'title': 'OpenRefine IDE'
        }
    }

