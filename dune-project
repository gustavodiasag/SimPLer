(lang dune 3.12)
(using menhir 2.1)

(name simpler)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name simpler)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune core core_unix ppx_deriving ppx_jane ounit2)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
