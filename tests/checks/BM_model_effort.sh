check_BM_model_effort() {
  sandbox_new BM
  load_panel 10 12 ""
  local tp="$HOME/.claude/projects/test-project/bm.jsonl"
  printf '%s\n%s\n%s\n' \
    '{"type":"assistant","effort":"medium","cwd":"/x/proj","timestamp":"2026-09-01T10:00:00.000Z","message":{"id":"m1","model":"claude-opus-5-5","usage":{"input_tokens":1,"output_tokens":1}}}' \
    '{"type":"assistant","effort":"high","timestamp":"2026-09-01T10:01:00.000Z","message":{"id":"m2","model":"claude-opus-5-5","usage":{"input_tokens":1,"output_tokens":1}}}' \
    '{"type":"assistant","effort":"low","timestamp":"2026-09-01T10:02:00.000Z","message":{"id":"m9","model":"<synthetic>","usage":{"input_tokens":0,"output_tokens":0}}}' > "$tp"
  assert_eq "the latest real reply's effort" "high" "$(session_identity_cached "$tp" | cut -f6)"
  assert_eq "read back from the cache the same" "high" "$(session_identity_cached "$tp" | cut -f6)"
  latest="$tp"; resolve_identity
  assert_eq "resolve_identity sets it" "high" "$model_effort"
  assert_eq "and the epoch is still its own field" "1788256800" "$sess_start_epoch"

  printf '%s\n' '{"type":"assistant","timestamp":"2026-09-01T10:00:00.000Z","message":{"id":"m1","model":"claude-opus-5-5","usage":{"input_tokens":1,"output_tokens":1}}}' > "$tp"
  assert_eq "none recorded is empty" "" "$(session_identity_cached "$tp" | cut -f6)"

  last_slow=$(panel_now); cols=80; last_cols=80
  model_label="Opus 5.5"; last_model_label="Opus 5.5"
  model_effort="high"; last_model_effort="high"
  slow_frame_due "$last_slow" && assert_eq "same effort: not due" "no" "yes" || assert_eq "same effort: not due" "no" "no"
  model_effort="max"
  slow_frame_due "$last_slow" && assert_eq "new effort: due" "yes" "yes" || assert_eq "new effort: due" "yes" "no"

  grep -q '"model_effort": text("MJ_MODEL_EFFORT")' "$PANEL_SH" \
    && assert_eq "the mod feed carries it" "yes" "yes" \
    || assert_eq "the mod feed carries it" "yes" "no"
  unset model_effort last_model_effort
}
