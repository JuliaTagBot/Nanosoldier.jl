# This file contains the default configuration settings for testing the CI
# tracking server that runs on the Nanosoldier cluster.

workers = addprocs(["nanosoldier5"])

@everywhere blas_set_num_threads(1)

import Nanosoldier, GitHub

config = Nanosoldier.ServerConfig(Nanosoldier.persistdir!(joinpath(homedir(), "workdir"));
                                  auth = GitHub.authenticate(ENV["GITHUB_AUTH"]),
                                  buildrepo = "jrevels/julia",
                                  reportrepo = "jrevels/BaseBenchmarkReports",
                                  makejobs = 7)
