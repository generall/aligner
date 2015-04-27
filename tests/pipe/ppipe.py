from subprocess import Popen, PIPE, STDOUT
import os, sys

slave = Popen(['ruby', os.path.dirname(os.path.realpath(__file__)) + '/../../pipe_launch.rb', "def"], stdin=PIPE, stdout=PIPE, stderr=STDOUT)


req_version = (2,7)
cur_version = (sys.version_info.major, sys.version_info.minor)

if cur_version > req_version:
	slave.stdin.write(bytes(str(2)   + "\n", "UTF-8"));
	slave.stdin.write(bytes("1 123"  + "\n", "UTF-8"));
	slave.stdin.write(bytes("12 123" + "\n", "UTF-8"));
	slave.stdin.write(bytes("12 123" + "\n", "UTF-8"));
	slave.stdin.close()
else:
	slave.stdin.write(bytes(str(2)   + "\n"));
	slave.stdin.write(bytes("1 123"  + "\n"));
	slave.stdin.write(bytes("12 123" + "\n"));
	slave.stdin.write(bytes("12 123" + "\n"));


while True:
	# check if slave has terminated:
	if slave.poll() is not None:
		break
	# read one line, remove newline chars and trailing spaces:
	line = slave.stdout.readline()
	if line != '':
		line = str(line.rstrip())
		print(line)
	else:
		break