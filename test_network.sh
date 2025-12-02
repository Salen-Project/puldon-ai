#!/bin/bash

echo "🔍 QUICK NETWORK TEST"
echo "===================="
echo ""

echo "1️⃣ Testing Mac internet connection..."
if ping -c 1 google.com > /dev/null 2>&1; then
    echo "   ✅ Mac has internet connection"
else
    echo "   ❌ Mac has no internet"
    exit 1
fi
echo ""

echo "2️⃣ Testing API server reachability..."
if ping -c 3 151.245.140.91 > /dev/null 2>&1; then
    echo "   ✅ API server is reachable (151.245.140.91)"
else
    echo "   ❌ Cannot reach API server"
    echo "   The server might be down or blocked"
    exit 1
fi
echo ""

echo "3️⃣ Testing API docs endpoint..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://151.245.140.91:8000/docs --max-time 5)
if [ "$HTTP_CODE" -eq 200 ]; then
    echo "   ✅ API docs endpoint responding (HTTP $HTTP_CODE)"
else
    echo "   ⚠️  API docs returned HTTP $HTTP_CODE"
fi
echo ""

echo "===================="
echo "📊 RESULT"
echo "===================="
echo ""
echo "✅ Your Mac can reach the API server!"
echo "✅ Network is working correctly!"
echo ""
echo "If iOS Simulator still shows 'No internet':"
echo "1. Close simulator completely"
echo "2. Run: flutter clean && flutter pub get"
echo "3. Restart simulator"
echo "4. Try again"
echo ""
echo "See NETWORK_TROUBLESHOOTING.md for more help."
echo ""
