############
# BuildRef #
############

type BuildRef
    repo::UTF8String  # the build repo
    sha::UTF8String   # the build + status SHA
    vinfo::UTF8String # versioninfo() taken during the build
end

BuildRef(repo, sha) = BuildRef(repo, sha, "?")

Base.summary(build::BuildRef) = string(build.repo, SHA_SEPARATOR, snip(build.sha, 7))

# if a PR number is included, attempt to build from the PR's merge commit
function build_julia!(config::Config, build::BuildRef, prnumber::Nullable{Int} = Nullable{Int}())
    # make a temporary workdir for our build
    builddir = mktempdir(workdir(config))
    cd(workdir(config))

    # clone/fetch the appropriate Julia version
    if !(isnull(prnumber))
        pr = get(prnumber)
        run(`git clone --quiet https://github.com/$(build.repo) $(builddir)`)
        cd(builddir)
        try
            run(`git fetch --quiet origin +refs/pull/$(pr)/merge:`)
        catch
            # if there's not a merge commit on the remote (likely due to
            # merge conflicts) then fetch the head commit instead.
            run(`git fetch --quiet origin +refs/pull/$(pr)/head:`)
        end
        run(`git checkout --quiet --force FETCH_HEAD`)
        build.sha = readchomp(`git rev-parse HEAD`)
    else
        run(`git clone --quiet https://github.com/$(build.repo) $(builddir)`)
        cd(builddir)
        run(`git checkout --quiet $(build.sha)`)
    end

    run(`make --silent`)

    cd(workdir(config))

    return builddir
end