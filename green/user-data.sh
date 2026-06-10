#!/bin/bash
set -e
apt-get update -y
apt-get install -y nginx curl

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)


cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Green — v2.0</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: #0a1f14;
      min-height: 100vh;
      font-family: 'Segoe UI', system-ui, sans-serif;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .grid-bg {
      position: fixed; inset: 0; z-index: 0;
      background-image:
        linear-gradient(rgba(34,197,94,0.07) 1px, transparent 1px),
        linear-gradient(90deg, rgba(34,197,94,0.07) 1px, transparent 1px);
      background-size: 40px 40px;
    }
    .glow { position: fixed; border-radius: 50%; filter: blur(90px); opacity: 0.15; pointer-events: none; }
    .glow-1 { width:350px; height:350px; background:#16a34a; top:-100px; right:-80px; }
    .glow-2 { width:300px; height:300px; background:#15803d; bottom:-80px; left:-60px; }
    .card {
      position: relative; z-index: 5;
      background: rgba(255,255,255,0.03);
      border: 1px solid rgba(74,222,128,0.2);
      border-radius: 16px;
      padding: 48px 56px;
      text-align: center;
      max-width: 480px;
      width: 90%;
    }
    .dot {
      width: 10px; height: 10px; border-radius: 50%;
      background: #4ade80; box-shadow: 0 0 10px #4ade80;
      margin: 0 auto 24px;
      animation: pulse 2s infinite;
    }
    @keyframes pulse { 0%,100%{opacity:1} 50%{opacity:0.3} }
    h1 {
      font-size: 2rem; font-weight: 300;
      letter-spacing: -0.5px; color: #dcfce7;
      margin-bottom: 6px;
    }
    .version {
      font-family: monospace; font-size: 12px;
      color: #4ade80; margin-bottom: 36px;
      letter-spacing: 1px;
    }
    .divider {
      width: 40px; height: 1px;
      background: rgba(74,222,128,0.25);
      margin: 0 auto 28px;
    }
    .info-row {
      display: flex; gap: 12px; justify-content: center;
      margin-bottom: 28px;
    }
    .info-chip {
      background: rgba(34,197,94,0.1);
      border: 1px solid rgba(74,222,128,0.2);
      border-radius: 8px;
      padding: 10px 16px;
      min-width: 130px;
    }
    .info-label {
      font-family: monospace; font-size: 10px;
      color: #4ade80; letter-spacing: 1px;
      margin-bottom: 4px;
    }
    .info-value {
      font-size: 13px; font-weight: 500; color: #dcfce7;
    }
    .desc {
      font-size: 13px; color: rgba(134,239,172,0.6);
      line-height: 1.6; font-family: monospace;
    }
  </style>
</head>
<body>
  <div class="grid-bg"></div>
  <div class="glow glow-1"></div>
  <div class="glow glow-2"></div>
  <div class="card">
    <div class="dot"></div>
    <h1>Green Environment</h1>
    <div class="version">VERSION 2.0 &nbsp;&middot;&nbsp; ENV: GREEN</div>
    <div class="divider"></div>
    <div class="info-row">
      <div class="info-chip">
        <div class="info-label">PUBLIC IP</div>
        <div class="info-value">$PUBLIC_IP</div>
      </div>
      <div class="info-chip">
        <div class="info-label">AZ</div>
        <div class="info-value">$AZ</div>
      </div>
    </div>
    <p class="desc">
      Green is the new release environment.<br/>
      Switch ALB listener to promote to production.<br/>
    </p>
  </div>
</body>
</html>
EOF

mkdir -p /var/www/html/health
cat > /var/www/html/health/index.html <<EOF
{"status":"healthy","env":"green","version":"2.0","ip":"$PUBLIC_IP","az":"$AZ"}
EOF

systemctl enable nginx
systemctl restart nginx