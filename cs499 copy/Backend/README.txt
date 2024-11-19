# Prerequisites
- Anaconda with Python (https://www.anaconda.com/download)

## Backend Setup

1. Checking prerequisite:
	-open terminal and type the command:
		conda --version
	-if the Anaconda is installed it should show its version, otherwise download and install it form the link in ##Prerequisites

2. Navigate to ../cs499/Backend directory

3. Create a new conda virtual environment by typing following command:
	conda create --name cs499_project python=3.7

4. Activate the virutal environment by typing the following command:
	conda activate cs499_project
    then run
    conda env list 
        this command should show all of your environments. environment with * next to its name is the one that is selected.
        if cs499_project is not selected, you will probably have to change the permissions in you OS to allow it (google or chatgpt it) 

5. Install the requirements by typing the following command:
	pip install -r requirements.txt

6. Run the application by typing the following command:
	flask run
	or
	python app.py

7. Leave the program running in this terminal
    it will show something like " * Running on http://127.0.0.1:5000" in terminal, and this will act as a backend server. It will not show anything on your browser