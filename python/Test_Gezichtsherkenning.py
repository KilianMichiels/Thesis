# -*- coding: utf-8 -*-
'''
Gezichtsherkenning: Voeg N gezichten toe aan de DB. Hoe goed scoort de applicatie?
Hoe?
    Kairos package voor python.
    Dataset downloaden met gezichten. Systematische namen geven en geleidelijk toevoegen aan Kairos database.
    Vervolgens gezichten laten herkennen.
    Controleren hoeveel van de N gezichten correct zijn.

    2D: Aantal personen in DB en aantal foto’s per persoon

Resultaat?
    In een grotere werkomgeving weet men hoe goed de gezichtsherkenning zal werken.
'''
# IMPORTS
from urllib2 import Request, urlopen
import os
import json
from glob import glob
import os
from os import listdir
import datetime
import numpy as np
from tqdm import tqdm, trange
import time

# KAIROS
import kairos_face
kairos_face.settings.app_id = 'acabd481'
kairos_face.settings.app_key = '335225fb385fe1cc0dcc4230025448cf'

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# Get all of the faces from the folders:

def listdir_nohidden(path):
    for f in os.listdir(path):
        if not f.startswith('.') and not f.startswith('Icon'):
            yield f

def get_faces(verbose):
    print('Getting faces...')
    faces = [f for f in listdir_nohidden(facesmap)]
    #print(facesFromMap)
    #print('-----------------------------------------------------------')

    print('''
    ---------------------------------------------
    Stats:
        Number of people: {}
        Number of faces per person: {}
        Total number of faces: {}
    ---------------------------------------------
    '''.format(len(faces)/20, 20, len(faces)))
    return faces, len(faces)

# Add face to the database:
def addPerson(faces, database_naam, NumberOfFacesPerPerson, NumberOfPersonsInDB, verbose, chillMode):
    if verbose:
        print('Adding {} files to {}'.format(NumberOfFacesPerPerson*NumberOfPersonsInDB, database_naam))

    personsInDatabase = []
    k = 0
    bar = tqdm(total=NumberOfPersonsInDB*NumberOfFacesPerPerson)
    while k < len(faces) and len(personsInDatabase) < NumberOfPersonsInDB*NumberOfFacesPerPerson:
        if k%20 == 0:
            for face in tqdm(range(NumberOfFacesPerPerson), leave = True):
                bar.update()
                try:
                    kairos_face.enroll_face(file=facesmap + faces[face+k], subject_id=str(k+1), gallery_name=database_naam)
                    personsInDatabase.append(k+1)
                    if chillMode:
                        time.sleep(2)
                except Exception as e:
                    if verbose:
                        print(bcolors.FAIL + "ERROR ADD PERSON: {}".format(e) + bcolors.ENDC)
                    time.sleep(30)
                    try:
                        kairos_face.enroll_face(file=facesmap + faces[face+k], subject_id=str(k+1), gallery_name=database_naam)
                        personsInDatabase.append(k+1)
                        if chillMode:
                            time.sleep(2)
                    except Exception as e:
                        if verbose:
                            print(bcolors.FAIL + "ERROR ADD PERSON: {}".format(e) + bcolors.ENDC)
                        else:
                            pass
                        if str(e).find('Max retries exceeded') > -1:
                            time.sleep(60)

        k += 1

    bar.close()
    return personsInDatabase

# Recognizing from a file
def recognisePerson(testdata, database_naam, NumberOfFaces, verbose, chillMode):
    correct = 0
    false = 0
    total = len(testdata)
    pbar = tqdm(total = len(testdata))
    for i, test in enumerate(testdata):
        if chillMode:
            time.sleep(2)
        try:
            data = kairos_face.recognize_face(file=test, gallery_name=database_naam)
            #print(data)
            #print('---------------------------------------------------------------')
            # Do something with the returned data:
            original_face_number = 0
            x = 1
            while x < NumberOfFaces:
                if x <= int(test[8:12]) <= x+20:
                    original_face_number = x
                    break
                else:
                    x += 20

            if 'images' in data:
                resultData = int(data['images'][0]['transaction']['subject_id'])

                if verbose:
                    print "\nI recognised the image as: {} \t | It has to be between: {} and {} \t | Original: {}\n".format(resultData, original_face_number, original_face_number+20, test[8:12])

                if resultData >= original_face_number and resultData <= original_face_number + 20:
                    correct += 1

                else:
                    false += 1

                if verbose:
                    print(bcolors.BOLD + 'Intermediar results: ' + bcolors.OKGREEN + '{} correct'.format(correct) + bcolors.ENDC + ' -- ' +
                    bcolors.FAIL + '{} wrong.\n'.format(false) + bcolors.ENDC)

        except Exception as e:
            if verbose:
                print(bcolors.FAIL + "ERROR RECOGNISE PERSON: {}".format(e) + bcolors.ENDC)
            else:
                pass
            if chillMode:
                time.sleep(30)

        pbar.update()

    pbar.close()
    return correct, len(testdata)



# MAIN (TEST)
if __name__ == '__main__':

    os.system('clear')

    print('''--------------------------------------------
TEST: Voeg N gezichten toe aan de DB.
      Hoe goed scoort de applicatie?

TEST: Add N faces to the database.
      How good does the application work?
--------------------------------------------
For this script, all the databases are already filled in.
Each database has a number of people in it and each person
has a number of photos. These numbers depend on the database.

At the end of the test the number of correct guesses will be
displayed. If you want, you can change the parameter 'verbose' to
'True' which will output extra information while
the program is running.

''')
    #--------------------------------------------------------#
    remove_database = False
    database = None
    #--------------------------------------------------------#
    NumberOfFacesPerPerson = None  # 0 - 20
    NumberOfPersonsInDB = None      # 0 - 370
    facesmap = 'faces95/'
    #--------------------------------------------------------#
    verbose = True
    chillMode = False
    #--------------------------------------------------------#
    addPeople = False
    testPeople = True
    #--------------------------------------------------------#

    possibilities = {
        '01'    :   ['TestDB1', 1, 50],
        '02'    :   ['TestDB2', 1, 100],
        '03'    :   ['TestDB3', 1, 200],
        '04'    :   ['TestDB4', 1, 370],
        '05'    :   ['TestDB5', 5, 50],
        '06'    :   ['TestDB6', 5, 100],
        '07'    :   ['TestDB7', 5, 200],
        '08'    :   ['TestDB8', 5, 370],
        '09'    :   ['TestDB9', 10, 50],
        '10'    :   ['TestDB10', 10, 100],
        '11'    :   ['TestDB11', 10, 200],
        '12'    :   ['TestDB12', 10, 370],
        '13'    :   ['TestDB13', 15, 50],
        '14'    :   ['TestDB14', 15, 100],
        '15'    :   ['TestDB15', 15, 200],
        '16'    :   ['TestDB16', 15, 370],
        '17'    :   ['TestDB17', 1, 72],
        '18'    :   ['TestDB18', 1, 224],
        '19'    :   ['TestDB19', 5, 72],
        '20'    :   ['TestDB20', 5, 224],
        '21'    :   ['TestDB21', 10, 72],
        '22'    :   ['TestDB22', 10, 224],
        '23'    :   ['TestDB23', 15, 72],
        '24'    :   ['TestDB24', 15, 224],
    }

    for x in sorted(possibilities):
        print('Possibility: {} \t| {} \t| {} \t| {}'.format(x,possibilities[x][0],possibilities[x][1], possibilities[x][2]))

    choice = raw_input('Which database would you like to use?\n')

    try:
        number = int(choice)
    except Exception as e:
        print('Please insert a number.')
        exit()

    for i in possibilities.keys():
        if i == choice:
            database = possibilities[choice][0]
            NumberOfFacesPerPerson = possibilities[choice][1]
            NumberOfPersonsInDB = possibilities[choice][2]
            break

    if database == None:
        print('Please choose one of the possibilities.')
        exit()

    #------------------------------------------------------------------------------#
    os.system('clear')

    print('-----------------------------------------------------------')
    print('|\tGezichtsherkenningstest')
    print('|\t{}'.format(datetime.datetime.now()))
    print('-----------------------------------------------------------')
    print('''|\tSettings:
|\t\tDatabase: {}
|\t\tRemove database: {}
|\t\tNumber of faces per person: {}
|\t\tNumber of people in database: {}
|\t\tVerbose: {}
|\t\tChill Mode: {}
|\t\taddPeople: {}
|\t\ttestPeople: {}'''.format(  database,
                                remove_database,
                                NumberOfFacesPerPerson,
                                NumberOfPersonsInDB,
                                verbose,
                                chillMode,
                                addPeople,
                                testPeople
                            ))
    print('-----------------------------------------------------------\n')
    #------------------------------------------------------------------------------#

    if remove_database:
        try:
            remove_gallery = kairos_face.remove_gallery(database)
        except Exception as e:
            if verbose:
                print(bcolors.FAIL + "ERROR REMOVE DB: {}".format(e) + bcolors.ENDC)
            else:
                pass

    galleries_list = kairos_face.get_galleries_names_list()
    if verbose:
        print('List of available galleries: {}\n'.format(json.dumps(galleries_list["gallery_ids"])))

    faces, NumberOfFaces = get_faces(verbose)

    peopleDB = None
    testData = []
    #print faces

    # Add people to the DB:
    if addPeople:
        if verbose:
            print('Starting to add people to the database...')
        peopleDB = addPerson(faces, database, NumberOfFacesPerPerson, NumberOfPersonsInDB, verbose, chillMode)
    else:
        gallery_subjects = kairos_face.get_gallery(database)
        peopleDB = gallery_subjects['subject_ids']
        print ('List of subjects in this database: {}\n'.format(json.dumps(peopleDB)))

    if testPeople:
        if verbose:
            print('Starting the test...')

        NumberOfFacesInTestData = int(NumberOfPersonsInDB*NumberOfFacesPerPerson/(100.0)*20)

        if verbose:
            print('''
        ---------------------------------------------
        Testing:
            Database = {}
            NumberOfFacesPerPerson = {}
            NumberOfFacesInTestData = {}
        ---------------------------------------------
        '''.format(database, NumberOfFacesPerPerson, NumberOfFacesInTestData))

        # generate testdata:
        for i in trange(NumberOfFacesInTestData):
            if testPeople:
                faceNumber = int(20*NumberOfPersonsInDB*np.random.random())
                face = facesmap + faces[faceNumber]
                while face in testData and face in peopleDB:
                    faceNumber = int(NumberOfPersonsInDB*NumberOfFacesPerPerson*np.random.random())
                    face = facesmap + faces[faceNumber]
                testData.append(face)

                # if verbose:
                #     print('{} -- Adding {} to the testdata {} as {}'.format(datetime.datetime.now(), face, database, face))


        correct, total = recognisePerson(testData, database, NumberOfFaces, verbose, chillMode)
        print('Total number of tests: {} -- Correct: {} = {} %'.format(total, correct, correct*100.0/total))

#------------------------------------------------------------------------------#
