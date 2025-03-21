set -e  # Exit on error

# Ensure required environment variables are set
#: "${MATTERBRIDGE_DISCORD_TOKEN:?Need to set MATTERBRIDGE_DISCORD_TOKEN}"
: "${MATTERBRIDGE_MATRIX_PASS:?Need to set MATTERBRIDGE_MATRIX_PASS}"

# Define paths
TEMPLATE_CONFIG="matterbridge.toml"
GENERATED_CONFIG="matterbridge.built.toml"
REMOTE_SERVER="root@nullring.xyz"
REMOTE_PATH="/etc/matterbridge.toml"

# Generate config file
sed "s|\${MATTERBRIDGE_MATRIX_PASS}|$MATTERBRIDGE_MATRIX_PASS|g" $TEMPLATE_CONFIG > $GENERATED_CONFIG

# Securely transfer to server
scp "$GENERATED_CONFIG" "$REMOTE_SERVER:$REMOTE_PATH"

# Restart Matterbridge service
ssh "$REMOTE_SERVER" "sudo systemctl restart matterbridge"

# delete config file with secrets from repo
shred -u "$GENERATED_CONFIG"

echo "✅ Matterbridge config deployed successfully!"
