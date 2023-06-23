# k-Wave

Source code of the o²S²PARC Service for k-Wave, A MATLAB toolbox for the time-domain simulation of acoustic wave fields. It uses the kspaceFirst3DG function to run 3D time-domain simulation of wave propagation on a GPU using C++ CUDA code. Find more information about k-Wave [here](http://www.k-wave.org/index.php).

It runs the kspaceFirstOrder-CUDA function (v1.3)

## Usage

```console
$ make help

$ make build
$ make info-build
$ make tests
```

## Workflow

1. The source code shall be copied to the [src](k-wave/src/k_wave) folder.
2. The [Dockerfile](k-wave/src/Dockerfile) shall be modified to compile the source code.
3. The [.osparc](.osparc) is the configuration folder and source of truth for metadata: describes service info and expected inputs/outputs of the service.
4. The [execute](k-wave/service.cli/execute) shell script shall be modified to run the service using the expected inputs and retrieve the expected outputs.
5. The test input/output shall be copied to [validation](k-wave/validation).
6. The service docker image may be built and tested as ``make build tests`` (see usage above)
7. Optional: if your code requires specific CPU/RAM resources, edit [runtime.yml](.osparc/runtime.yml). In doubt, leave it as default.

## Have an issue or question?
Please open an issue [in this repository](https://github.com/ITISFoundation/cookiecutter-osparc-service/issues/).
---
<p align="center">
<image src="https://github.com/ITISFoundation/osparc-simcore-python-client/blob/4e8b18494f3191d55f6692a6a605818aeeb83f95/docs/_media/mwl.png" alt="Made with love at www.z43.swiss" width="20%" />
</p>

## Citing the k-Wave Toolbox
If you find the toolbox useful for your academic work, please consider citing one or more of the associated papers, more information [here](http://www.k-wave.org/license.php).