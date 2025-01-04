# OpenDtwa
OpenDtwa is a simulation framework based on open discrete truncatedWigner approximation (ODTWA) for simulating the dynamics of interacting spin ensembles in the presence of dephasing and decay. This repository contains the core simulation logic and tools for analyzing such systems, including configurations, solvers, and various modules. The package is developed based on the theoretical framework discussed in the paper: **"PHYSICAL REVIEW A 105, 013716 (2022)"** *DOI: [https://doi.org/10.1103/PhysRevA.105.013716](https://doi.org/10.1103/PhysRevA.105.013716)*

## Features
- Simulate disordered systems using different parameters and configurations.
- Parallel processing support for faster computations.
- Configurable system size, decay rates, magnetic field components, and more.
- Results are stored and can be analyzed in various ways.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [Directory Structure](#directory-structure)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Installation

### Prerequisites
- Julia (1.x or later) should be installed on your system.

### Installation Steps

1. **Clone the repository:**

    ```bash
    git clone https://github.com/javahedi/OpenDtwa.git
    cd OpenDtwa
    ```

2. **Activate the environment:**

    Ensure you're using the correct Julia environment:

    ```bash
    julia --project=.
    ```

3. **Install dependencies:**

    Once inside the `OpenDtwa` project, run:

    ```julia
    using Pkg
    Pkg.instantiate()
    ```

4. **Run the simulations:**

    You can now run the simulations using the provided script (`main.jl`).

    ```bash
    julia --project=./OpenDtwa -t 4 main.jl
    ```

## Usage

1. **Running Simulations:**

    The main entry point for simulations is the `main.jl` script. You can run the simulation in parallel by specifying the number of threads or processes to use.

    Example:

    ```bash
    julia --project=./OpenDtwa -t 4 main.jl
    ```

    This runs the simulation using 4 threads. Alternatively, for distributed processes:

    ```bash
    julia --project=./OpenDtwa -p 4 main.jl
    ```

2. **Configuration:**

    The `config.json` file contains the default configuration for the simulations. You can modify this file to set your own parameters such as lattice size, decay rates, and magnetic field components. If the configuration file is not present, the default values from `configs.jl` are used.

3. **Output:**

    The results of the simulations are saved in the `DATA` directory, with subdirectories for each set of simulation parameters (e.g., `alpha1.0`, `alpha2.0`). Each result is stored in BSON format, which can be loaded and analyzed later.

## Directory Structure

Here's an overview of the directory structure:

```
├── DATA                # Simulation result data
│   ├── alpha1.0        # Results for α = 1.0
│   ├── alpha2.0        # Results for α = 2.0
│   └── alpha3.0        # Results for α = 3.0
│   
├── OpenDtwa            # Core Julia package
│   ├── Manifest.toml    # Project dependencies
│   ├── Project.toml     # Project configuration
│   └── src              # Source code
│       ├── OpenDtwa.jl  # Main simulation logic
│       ├── configs.jl   # Configuration file
│       ├── modules.jl   # Various modules for simulations
│       └── solvers.jl   # Solver functions
├── config.json          # Configuration file (JSON format)
├── magnetization.pdf    # Example plot
├── main.jl              # Main entry point for running simulations
├── plot.jl              # Script for plotting results
└── test                 # Unit tests
    └── runtest.jl       # Test script
```

## Testing

To run the tests for this package, navigate to the `test` folder and run:

```bash
julia --project=./OpenDtwa test/runtest.jl
```

This will execute the tests in the `runtest.jl` script, which checks the functionality of the core modules and configurations.

## Contributing

We welcome contributions to improve the OpenDtwa project. If you'd like to contribute, please fork the repository, make your changes, and submit a pull request.

### My Contribution

The development of this package is based on the theoretical framework discussed in the paper *PHYSICAL REVIEW A 105, 013716 (2022)*, and I have contributed to the implementation and extension of the simulation framework for studying disordered systems. I have made several updates to the codebase, including modules for simulations, solvers, and configuration management.

### Collaboration

I am open to any collaboration, improvements, or suggestions. If you find bugs, want to extend the functionality, or have questions, feel free to create an issue or submit a pull request.

### Steps for contribution:
1. Fork this repository.
2. Create a new branch (`git checkout -b feature-name`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add new feature'`).
5. Push to the branch (`git push origin feature-name`).
6. Open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

### Explanation of Updates:
1. **Contribution Section**: A section titled "My Contribution" has been added where you acknowledge your work and contributions to the project.
2. **Collaboration Invitation**: Added a note encouraging collaboration and offering assistance for any issues or improvements.
3. **Citation of the Paper**: The theoretical framework is properly attributed in the section where you explain the origin of the work.

Now your `README.md` provides information on the source of the theoretical foundation, credits your contributions, and welcomes others to collaborate.

Once this is ready, you can commit and push the updated `README.md`:

```bash
git add README.md
git commit -m "Added contribution and collaboration section"
git push origin main
```

Let me know if you'd like to make any further adjustments!
