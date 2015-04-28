import sublime, sublime_plugin
from subprocess import Popen, PIPE, STDOUT
import os, sys

DEBUG = False

def log(s):
	if DEBUG:
		print(s)


class AlignerCommand(sublime_plugin.TextCommand):
	def run(self, edit, lang='default'):
		#self.view.insert(edit, 0, "HW")
		lines = []
		log(lang)
		#path = "/home/generall/Dropbox/code/Ruby/aligner"
		path = sublime.packages_path() + "/AutoAligner"
		prev_dir = os.getcwd();
		os.chdir(path)
		
		for line in self.view.sel():
			lines_region = self.view.line  (line        );
			txt_lines    = self.view.substr(lines_region);
			lines = txt_lines.split("\n");

			for l in lines:
				log(l)
			log("---")

			try:
				slave = Popen(['ruby', path + '/pipe_launch.rb', lang], stdin=PIPE, stdout=PIPE, stderr=STDOUT)
				
				if sys.version_info >= (3,):
					slave.stdin.write(bytes(str(len(lines)) + "\n" , "UTF-8"));
					slave.stdin.write(bytes(txt_lines       + "\n" , "UTF-8"));
					slave.stdin.close()
				else:
					slave.stdin.write(bytes(str(len(lines)) + "\n" ));
					slave.stdin.write(bytes(txt_lines       + "\n" ));
					
	
				log("patch: " + path)
	
				result = []
				while True:
					# check if slave has terminated:
					if slave.poll() is not None:
						break
					# read one line, remove newline chars and trailing spaces:
					line = slave.stdout.readline().rstrip()
					log(line)
					result.append(line.decode("utf-8"))
				responce = '\n'.join(result)
				responce = responce.rstrip('\n')
				self.view.replace(edit, lines_region, responce);
				self.view.sel().clear()
			except OSError as e:
				if e.errno == os.errno.ENOENT:
					sublime.error_message("ruby is not installed")

		os.chdir(prev_dir)

			##self.view.insert(edit, 0, '\n'.join(result))
