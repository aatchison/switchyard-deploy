#!/usr/bin/env bash
# Install the switchyard systemd user units from this repo, rewriting the
# hard-coded paths to point at THIS checkout. Idempotent.
#
#   scripts/install-units.sh            # install both (main :4001, v0.2.0 :4000)
#   scripts/install-units.sh main       # only main
#
# Requires: deploy/.env with ANTHROPIC_API_KEY (mode 600), and the images built
# (see README "Build").
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
dest="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
mkdir -p "$dest"

[ -f "$here/deploy/.env" ] || { echo "missing $here/deploy/.env (copy deploy/.env.example)" >&2; exit 1; }
chmod 600 "$here/deploy/.env"

want="${1:-both}"
install_unit() {
  local unit="$1" src="$here/systemd/$1"
  # Units ship with %h/switchyard-deploy as the checkout path; point them here.
  sed -e "s#%h/switchyard-deploy#$here#g" "$src" > "$dest/$unit"
  echo "installed $dest/$unit"
}
case "$want" in
  main|both) install_unit container-switchyard-main.service ;;
esac
case "$want" in
  v020|both) install_unit container-switchyard.service ;;
esac
systemctl --user daemon-reload
echo "next: systemctl --user enable --now container-switchyard-main.service   # then: switchyardctl status"
