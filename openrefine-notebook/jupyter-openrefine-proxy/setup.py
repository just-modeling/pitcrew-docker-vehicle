import setuptools
 
setuptools.setup(
    name="jupyter-openrefine-proxy",
    version='1.0',
    url="https://github.com/ksmc/management-guidance",
    author="Project Jupyter Contributors",
    description="projectjupyter@gmail.com",
    packages=setuptools.find_packages(),
	keywords=['Jupyter'],
	classifiers=['Framework :: Jupyter'],
    install_requires=[
        'jupyter-server-proxy'
    ],
    py_modules=['jupyter_openrefine_proxy'],
    entry_points={
        'jupyter_serverproxy_servers': [
            'openrefine = jupyter_openrefine_proxy:setup_openrefine',
        ]
    }
)

