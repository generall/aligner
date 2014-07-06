import sublime, sublime_plugin
from subprocess import Popen, PIPE, STDOUT
import os

class AlignerCommand(sublime_plugin.TextCommand):
	def run(self, edit):
		#self.view.insert(edit, 0, "HW")
		lines = []
		
		#path = "/home/generall/Dropbox/code/Ruby/aligner"
		path = sublime.packages_path() + "/aligner"
		prev_dir = os.getcwd();
		os.chdir(path)
		
		for line in self.view.sel():
			lines_region = self.view.line  (line        );
			txt_lines    = self.view.substr(lines_region);
			lines = txt_lines.split("\n");


			slave = Popen(['ruby', path + '/pipe_launch.rb'], stdin=PIPE, stdout=PIPE, stderr=STDOUT)
			slave.stdin.write(bytes(str(len(lines)) + "\n" , "UTF-8"));
			slave.stdin.write(bytes(txt_lines       + "\n" , "UTF-8"));

			result = []
			while True:
			    # check if slave has terminated:
			    if slave.poll() is not None:
			        break
			    # read one line, remove newline chars and trailing spaces:
			    line = slave.stdout.readline().rstrip()
			    #print 'line:', line
			    result.append(line.decode("utf-8"))
			responce = '\n'.join(result)
			responce = responce.rstrip('\n')
			self.view.replace(edit, lines_region, responce);
			self.view.sel().clear()

		os.chdir(prev_dir)

			##self.view.insert(edit, 0, '\n'.join(result))
