default: lint

lint: compile tidy

compile:
	find . -type f -name "*.pl" -exec perl -c {} \;
	find . -type f -name "*.pm" -exec perl -c {} \;

tidy:
	find . -type f -name "*.pm" -exec perltidy -b {} \;
	find . -type f -name "*.pl" -exec perltidy -b {} \;

clean:
	find . -type f -name "*.bak" -exec rm {} \;

dev:
	morbo scripts/guardian
