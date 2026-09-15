function submit_jobs () {
  # NOTE: `m` & `n` are first & last image, inclusive
  m=$1
  n=$2
  # Line renumbering offset
  k=$((m-1))
  # Submit each job separately
  for i in $(seq $m $n); do
    condor_submit source/hypro-pelican2/hypro.sub image_number=$i line_number=$((i-k)) "${@:3}";
  done
}
