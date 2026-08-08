# 宿題ハンター — Development Guide

**Vision:** 宿題の面倒くささが、倒すと気持ちいいモンスターに変わる世界
**Mission:** 学習への抵抗感を、ボス撃破の爽快感に変換する

設計書: `homework-hunter-design-v1_1.md` / 引き継ぎ書: `quest-block-code-handoff-v1_0.md`（v1.1差分は本ファイルで補完）

---

## 技術スタック

- Flutter 3.44 + Riverpod（StateNotifier/Provider、riverpod_generator は未使用）
- ゲームロジック: Flame
- 課金: RevenueCat（**未設定・ブロック中**）
- バックエンド: Firebase Firestore/Auth/Analytics（**未設定・ブロック中**）

---

## 現在の状態（2026-07-10）

### 実装済み（ローカルモックで動作）
- プロジェクト初期化・ディレクトリ構成
- モデル: `Stage` / `UserProgress` / `AppUser`
- `StageRepository`: ステージ1（漢字ゴブリン）を Easy/Normal/Hard の3難易度でローカル固定データ提供
- `ProgressStore`: クリア状況・ストリークを SharedPreferences に保存
- `AnalyticsService`: 現状は `debugPrint` のみ（Firebase Analytics 未接続）
- ボス戦闘: プレイヤーHP3・ボスが4秒間隔で反撃（1ダメージ）。HP0で敗北→リトライダイアログ
  （タップダメージのみの仕様から、ユーザー確認の上で反撃要素を追加）
- ボス戦闘の見た目強化: グラデーション背景、パーツ組み立て式ゴブリンフェイス（角・眉・目・牙）、
  タップ時のパンチ演出＋ダメージ数値ポップアップ、反撃前の「!」テレグラフ＋振動演出、
  撃破時の回転縮小演出、HPバーの残量に応じた色変化（緑→オレンジ→赤）
  （実機テストで `onGameResize` が `onLoad` 完了前に呼ばれ `late` フィールド未初期化クラッシュを
  検出→nullable化して修正。ホーンの回転がPolygonComponentのデフォルトanchor(topLeft)で
  ずれる不具合も実機確認で発見→`anchor: Anchor.center`指定で修正）

### ⏸ ユーザー待ち（ブロック中）
- Firebase プロジェクト作成・`google-services.json` 配置 → [flutter-firebase-setup] スキルで対応
- RevenueCat アカウント作成・Product ID (`jp_quest_block_480_1m` 相当) 登録
- 上記が揃うまで `AnalyticsService` / `StageRepository` / `ProgressStore` は
  ローカル実装のまま。Firestore/RevenueCat 導入時にこの3クラスを差し替える
  （呼び出し側のインターフェースは変えない設計にしてある）。

---

## Must 機能（v1.1）

1. ステージ選択・難易度選択（Easy/Normal/Hard）
2. ブロック配置パズル + 配置正解可視化（ヒント／方式B: 矢印アイコンから着手）
3. ボス戦闘（Flame・宿題モンスターモチーフ）
4. クリア後：一時クリエイティブモード解放（60秒）
5. ペイウォール＆購入機能（RevenueCat ブロック中のため後回し）

---

## 計測イベント（6個）

`aha_moment_reached` / `stage_clear` / `boss_defeated` / `paywall_viewed` /
`purchase_completed` / `cross_promo_tapped`

---

## 実装順序

Phase 1（セットアップ）→ Phase 2（Aha最短動線: ホーム→ステージ選択→ブロック配置→ボス戦→クリア）
→ Phase 3（全機能・Firestore/RevenueCat 本接続）→ Phase 4（UI/UX）→ Phase 5（テスト）→ Phase 6（ソフトローンチ）

詳細は `quest-block-code-handoff-v1_0.md` のチェックリストを参照（テーマ差分は本ファイルが優先）。
