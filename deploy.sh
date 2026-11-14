#!/bin/sh
# 2027 정미년 사주풀이 — GitHub Pages 배포 스크립트
# 사용 전제: github.com/annjsy18-sys/saju2027 저장소가 (빈 저장소로) 이미 존재해야 합니다.
#   GitHub 앱 권한에 저장소 생성 권한이 없어, 저장소는 github.com/new 에서 한 번 직접 만들어 둡니다.
set -e
REPO="annjsy18-sys/saju2027"
cd "$(dirname "$0")"

if ! git remote | grep -q origin; then
  git remote add origin "https://github.com/$REPO.git"
fi

echo "== 1) 소스 푸시 =="
git push -u origin main

echo "== 2) GitHub Pages 활성화 (main / 루트) =="
gh api -X POST "repos/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" 2>/dev/null \
  || gh api -X PUT "repos/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" 2>/dev/null \
  || echo "!! Pages API 권한이 없습니다. 저장소 Settings > Pages > Source: Deploy from a branch > main / (root) 를 직접 선택해야 합니다."

echo "== 3) 배포 상태 확인 =="
for i in $(seq 1 20); do
  code=$(curl -s -o /dev/null -w "%{http_code}" "https://annjsy18-sys.github.io/saju2027/")
  echo "  try $i: HTTP $code"
  [ "$code" = "200" ] && break
  sleep 15
done
echo "== 주소: https://annjsy18-sys.github.io/saju2027/ =="
