# Build system for Turtl (on sane build systems)

This is a collection of Makefiles and Dockerfiles to build Turtl
(core/js/desktop) on sane build systems (linux). OSx, iOS, Windows are left out
because they require special hardware or licenses. I build on these platforms
manually, with custom scripts.

Supported targets/platforms:

- core
  - android arm64
  - android armv7
  - linux x64
  - linux x32
- desktop
  - linux x64
  - linux x32

Missing:

- core
  - windows x64
  - windows x32
  - OSx
  - iOS
- desktop
  - windows x64
  - windows x32
  - OSx
- mobile
  - android (planned, this could be easily containerized)
  - iOS

If you have suggestions for how to support these platforms in a repeatable way,
they would be greatly appreciated. Feel free to use the [Turtl project tracker](https://github.com/turtl/tracker)
for suggestions, and pull requests are welcome as well. Keep in mind, any
solutions *must not* use third-parties to build (no outside services or CI tools
can be used for builds)...if we start building on other people's machines, we
lose a lot of trust.

Missing platforms aside, if nothing else you can use these files as a reference
for the process of building the [turtl core](https://github.com/turtl/core-rs)
and how it fits in to the desktop/android apps.

## Usage

For each of the targets you want to build for (`core/arm64`, `desktop/linux64`,
etc) you'll want to create the Docker build container. This should be fairly
painless:

```sh
cd core/linux64
make
```

Wow, that's it. You now have a container that can build that particular Turtl
target.

Now (in the same folder) run it:

```sh
make run
```

This will run the build. For a list of all available targets, see the root
[Makefile](https://github.com/turtl/build/blob/master/Makefile).

## Problems? Questions?

This build system is provided AS-IS and is available mostly as a reference to
people seeking to build the client themselves. It's not a project we're
officially supporting at the moment.

If you have a problem and the fix could help others, pull requests are highly
encouraged.

