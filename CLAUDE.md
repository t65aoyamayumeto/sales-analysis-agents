# Sales Deal Evaluation Pipeline

NotionをCRMに見立てた案件評価パイプライン。
Notion MCPで案件DBを取得し、3つのSalesエージェントが直列に評価し、
結果をマネージャー向けダッシュボードページとして書き出す。

## エージェント実行順序（直列）

1. **Deal Strategist** (`~/claude-pipeline/skills/deal-strategist.md`)
   - MEDDPICC採点・競合ポジショニング・勝ち筋
   - アウトプット粒度: 案件単位
2. **Pipeline Analyst** (`~/claude-pipeline/skills/pipeline-analyst.md`)
   - パイプライン全体の健全性・速度・カバレッジ・予測
   - アウトプット粒度: ポートフォリオ単位（前段の案件評価を入力）
3. **Sales Coach** (`~/claude-pipeline/skills/sales-coach.md`)
   - 担当者別の改善・コーチング指針・1on1議題
   - アウトプット粒度: 担当者別行動指針（前段2つを入力）

## データソース

- Notion 案件DB: 検証用CRM (`NOTION_CRM_PAGE_ID_REDACTED`) 配下に作成する `Deals` データベース

## 出力先

- Notion 親ページ: 検証用ダッシュボード (`NOTION_DASHBOARD_PAGE_ID_REDACTED`)
- 生成物: パイプライン実行毎に `Deal Review Dashboard YYYY-MM-DD` ページを新規作成

## ガードレール

- ペルソナはローカルmdファイル（`~/claude-pipeline/skills/*.md`）から必ず読み込む
- 案件データの捏造禁止。Notion DBから取得したフィールドのみ参照
- 数値・固有名詞は出典フィールドを明記
- 各エージェントは前段アウトプットを入力に取り、独立に最終結論を述べる

## パイプライン実行手順

1. Notion MCPで `Deals` DBを fetch（全案件取得）
2. Deal Strategist: 各案件のMEDDPICCスコアと verdict を生成
3. Pipeline Analyst: 1の結果＋全案件データから健全性・速度・予測を生成
4. Sales Coach: 1+2 の結果から担当者別コーチングプランを生成
5. ダッシュボードページを Notion に作成（3つのセクションを統合）
