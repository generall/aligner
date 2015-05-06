task default: %w[test]

task :test do
	`bash "tests/general/test.sh"`
	fail "test general failed" if $?.to_i > 0 
end