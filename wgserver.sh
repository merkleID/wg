privkey=$(wg genkey | tee private | wg pubkey)
echo $privkey
