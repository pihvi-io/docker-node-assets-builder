# Node assets builder
This is docker container for building frontend web assets recursively from multiple subfolders with grunt, gulp or webpack. (More tools will be added when they became popular).

This container is designed for CMS projects like Drupal or WordPress which can have multiple different themes in one project.

You can download the image by running:
```bash
$ docker pull pihvio/node-assets-builder
```

## How it works
1. It searches directories with `package.json` and `bower.json`
2. It installs packages from those files with yarn or bower
3. It searches `Gruntfile.js`,`gulpfile.js` and `webpack.js` from those same directories
4. It builds all of the founded files with default configurations

## Example theme setup

Here's an example theme folder structure which can be builded with this project:
```
/build/themes
├── theme1
│   ├── package.json
│   └── webpack.js
├── theme2
│   ├── Gruntfile.js
│   ├── bower.json
│   └── package.json
└── theme3
    ├── gulpfile.js
    └── package.json
```

In this example we would use following envs: `MAX_DEPTH=3` and `BUILD_DIR=/build/themes`:
```
$ docker run -v ./themes:/build/themes -e MAX_DEPTH=3 -e BUILD_DIR=/build/themes pihvio/node-assets-builder
```

You don't want to use too big value in `MAX_DEPTH` because it will cause chain reaction which installs the dependencies from `node_modules` again and again.

## Configuration through envs

`PACKAGE_INSTALLER` - This defines the default `package.json` installer. It can be either `npm` or `yarn` (default: `yarn`).

`NODE_VERSION` - The container contains [nvm](https://github.com/creationix/nvm) for using a custom nodejs version. If you define this the container automatically uses custom nodejs version for everything.

`MAX_DEPTH` - This is the maximum depth for looking for `package.json` and `bower.json` (default: 1).

## docker-compose.yml example
```yaml
version: '3'

services:
  assets:
    image: pihvi/node-assets-builder
    environment:
      MAX_DEPTH: 3
      NODE_VERSION: v8.1.2
      PACKAGE_INSTALLER: npm
      BUILD_DIR: /build/themes
    volumes:
      - ./themes:/build/:rw,cached
    command: asset-builder
```

## Maintainers
[Onni Hakala](https://github.com/onnimonni)

## License
MIT