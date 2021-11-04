import yaml, sys        #python3 -m pip install --upgrade PyYAML (yaml must be minimum 5 version)

print('PyYAML version: ' + yaml.__version__)

#Makes the output pretty
from rich.console import Console
console = Console()

if __name__ == '__main__':

    yamlFile = open(sys.argv[1], 'r')             #opening file from given argument and storing it as textfile object
    yamlObject = yaml.load(yamlFile, Loader=yaml.FullLoader)  #loading opened file using yaml loader and storing it as yaml object
    for key, value in yamlObject.items():
        console.print(key + ':' + str(value))   #rich module print function

#python ./yaml.py myfile.yml 
