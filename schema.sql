CREATE TABLE course ('pk' INTEGER PRIMARY KEY, 'courseName' CHAR(255), 'courseData' CHAR(48), 'lastDate' REAL, 'holeNumber' INTEGER , 'sr' INTEGER, 'cr' INTEGER);
CREATE TABLE coursehole ('courseID' INTEGER, 'holeID' INTEGER, 'whitePar' INTEGER, 'blackPar' INTEGER, 'whiteYard' INTEGER, 'blackYard' INTEGER, 'bluePar' INTEGER, 'blueYard' INTEGER, 'orangePar' INTEGER, 'orangeYard' INTEGER, 'hcp' INTEGER);
CREATE TABLE hole ('scoreID' INTEGER, 'holeID' INTEGER, 'strokeNum' INTEGER, 'strokeNum2' INTEGER, 'strokeNum3' INTEGER, 'strokeNum4' INTEGER);
CREATE TABLE score ('pk' INTEGER PRIMARY KEY, 'courseID' INTEGER, 'playDate' REAL, 'player2Name' CHAR(48), 'player3Name' CHAR(48), 'player4Name' CHAR(48), 'holeNumber' INTEGER, 'status' INTEGER, 'hcp' INTEGER, 'hcp2', INTEGER, 'hcp3' INTEGER, 'hcp4' INTEGER);
CREATE TABLE stroke ('scoreID' INTEGER, 'holeID' INTEGER, 'strokeNum' INTEGER, 'distance' INTEGER, 'longitude' DOUBLE, 'latitude' DOUBLE, 'putt' INTEGER);
