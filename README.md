# dockspec #

`dockspec` is an emacs minor mode to run rspecs tests in a docker
container. It now
uses [dockrun](https://github.com/jcinnamond/dockrun) to run the
specs.

It expects a suitable container capable of running `rspec` for your
project, and then tests the current file by running `dockrun client
spring rspec <the path to your spec>`. The output appears in a
compilation buffer and the standard `next-error` and `previous-error`
bindings should work.

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

Make sure docker is running an instance capable of running rspec, with
`dockrun server` running and the dockrun port forwarded.

To get started with setting up rails and docker, see this
[guide to setting up docker and rails](https://docs.docker.com/compose/rails/)
on the docker site.

The rest of this guide assumes that your `Dockerfile` installs
dockrun. I do this by adding something like the follow:


	RUN wget -q -O /usr/bin/dockrun https://github.com/jcinnamond/dockrun/releases/download/v0.1.1/dockrun
	RUN chmod +x /usr/bin/dockrun

I also ensure that the docker instance starts in my project root, with
something like:

	ADD . /code
	WORKDIR /code/project

(`project` would typically be replaced with the name of your project)

In your docker compose file, create a service called `test` that
starts `dockrun`. For example, add something like:


    test:
      build: .
      volumes:
        - .:/app
      command: /usr/bin/dockrun server
      ports:
        - "9178:9178"
      depends_on:
        - test-db
      environment:
        - RAILS_ENV=test
        - DATABASE_URL=postgresql://indigoand:indigoand@test-db/indigoand_test

	test-db:
      image: postgres
      environment:
        - POSTGRES_USER=user
        - POSTGRES_PASSWORD=password
        - POSTGRES_DB=project_test

Make sure that you can communicate with this instance by running
`dockrun client hostname` from your host machine.

### Running specs ###

`dockspec` provides four keybindings for running specs. Assuming you
are in an rspec file and dockfile is loaded, you can run:

 - `C-c , v` to test the current file
 - `C-c , s` to run the test at the current line
 - `C-c , a` to run all of the specs for a project

In a non-spec ruby file you can run:

 - `C-c , r` to rerun the last spec

### Configuring dockspec ###

You can configure most aspects of dockspec to suit your environment.
To change these values run `customize-group dockspec` or set the
values in your config file.

The following variable are available for controlling how
`docker-compose` is run:

 - `dockspec-dockrun-command` (defaults to `dockrun client`)

You can also override the command used to run the tests:

 - `dockspec-test-command` (defaults to `spring rspec`)

Together, these variables combine to produce the compile command:

	dockrun client spring rspec

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
