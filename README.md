# dockspec #

`dockspec` is an emacs minor mode to run rspecs tests in a docker
container.

It expects a suitable container capable of running `rspec` for your
project, and then tests the current file by running `docker-compose
run --rm <the name of your service> rspec <the path to your spec>`.
The output appears in a compilation buffer and the standard
`next-error` and `previous-error` bindings should work.

This package has been heavily inspired
by [rspec-mode](https://github.com/pezra/rspec-mode).

## Installation ##

Download the package and add it to your load path.

You can load the minor mode in any ruby buffer by running `dockspec`.
I have it configured to run automatically in spec files by adding the
following to my config:

	    (add-hook 'ruby-mode-hook (lambda ()
                                    (if (buffer-file-name)
                                        (if (string-match "_spec\\.rb\\'" buffer-file-name)
                                            (dockspec)))))


## Using the package ##

### docker setup ###

Make sure docker set up and running on your machine, and a
`Dockerfile` configured for your project. If not, there is a
[guide to setting up docker and rails](https://docs.docker.com/compose/rails/)
on the docker site.

The rest of this guide assumes that your directory layout is something
like:

	project_root/
		Dockerfile
		docker-compose.yml
		project/
			<the ruby/rails project>

It also assumes that your `Dockerfile` contains:

	ADD . /code
	WORKDIR /code/project
	ENTRYPOINT ["bundle", "exec"]

(`project` would typically be replaced with the name of your project)

In your docker compose file, create a service called `test` that can
run the specs. For example, add something like:

	test:
      build: .
      volumes:
        - .:/code
      command: rake spec
      depends_on:
        - test-db
      environment:
        - RAILS_ENV=test
        - DATABASE_URL=postgresql://user:password@test-db/project_test

	test-db:
      image: postgres
      environment:
        - POSTGRES_USER=user
        - POSTGRES_PASSWORD=password
        - POSTGRES_DB=project_test

Make sure that you can run the specs by running `docker-compose run
--rm test rspec`

### Running specs ###

`dockspec` provides three keybindings for running specs. Assuming you
are in an rspec file and dockfile is loaded, you can run:

 - `C-c , v` to test the current file
 - `C-c , s` to run the test at the current line
 - `C-c , a` to run all of the specs for a project.

### Configuring dockspec ###

You can configure most aspects of dockspec to suit your environment.
To change these values run `customize-group dockspec` or set the
values in your config file.

The following variables are available for controlling how
`docker-compose` is run:

 - `dockspec-docker-command` (defaults to `docker-compose`)
 - `dockspec-run-command` (defaults to `run`)
 - `dockspec-run-flags` (defaults to `--rm`)
 - `dockspec-service-name` (defaults to `test`)

You can also override the command used to run the tests:

 - `dockspec-test-command` (defaults to `rspec`)

Together, these variables combine to produce the compile command:

	docker-compose run --rm test rspec

(the name and line number are added to the end of this command, as
appropriate)

You can also override the prefix for running dockspec commands:

 - `dockspec-key-command-prefix` (defaults to `kdb "C-c ,"`)

Finally, there is an option to explicitly set the project root.
Normally, dockspec tries to work this out by searching for `Rakefile`,
`Gemfile`, or `.git` in the parent directories of the current file. If
your setup doesn't match this then you can override it by setting
`dockspec-project-root` to an absolute path. Unfortunately this is set
globally so it will affect all projects.

## Licence ##

Copyright 2016 John Cinnamond

This mode is distributed under the same licence as GNU Emacs.

GNU Emacs is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3, or (at your option)
any later version.

GNU Emacs is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU Emacs; see the file COPYING.  If not, write to the
Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
Boston, MA 02110-1301, USA.
