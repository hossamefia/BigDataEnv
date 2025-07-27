c = get_config()

# Basic configuration
c.NotebookApp.token = 'bigdata123'
c.NotebookApp.password = ''
c.NotebookApp.allow_root = True
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.notebook_dir = '/home/jovyan/work'

# Enable extensions
c.NotebookApp.nbserver_extensions = {
    'jupyter_server_proxy': True
}

# Set up Spark configuration
import os
os.environ['SPARK_HOME'] = '/usr/local/spark'
os.environ['PYSPARK_DRIVER_PYTHON'] = 'jupyter'
os.environ['PYSPARK_DRIVER_PYTHON_OPTS'] = 'lab'
os.environ['PYSPARK_PYTHON'] = '/opt/conda/bin/python'

# Auto-start Spark context
c.InteractiveShellApp.exec_lines = [
    "import findspark",
    "findspark.init()",
    "from pyspark.sql import SparkSession",
    "from pyspark import SparkContext, SparkConf",
    "import pandas as pd",
    "import numpy as np",
    "import matplotlib.pyplot as plt",
    "import seaborn as sns",
    "print('Big Data Environment Ready!')",
    "print('Spark Session will be created when you run: spark = SparkSession.builder.appName(\"BigDataApp\").enableHiveSupport().getOrCreate()')"
]