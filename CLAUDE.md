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

## トリアージ設定

エージェント評価前に以下の条件で案件を絞り込む（`skills/deal-triage.md` 参照）。

| 条件 | 値 | 備考 |
|-----|---|------|
| include_stages | `Qualify`, `Discovery`, `Proposal`, `Negotiation` | |
| exclude_stages | `Prospect`, `Closed Won`, `Closed Lost` | |
| active_within_days | `45` | Last Activity が未設定の場合は通過 |
| min_deal_size | なし | |
| close_date_within_days | なし | |

## データソース

- Notion 案件DB: `NOTION_CRM_PAGE_ID` 配下に作成する `Deals` データベース

## 出力先

- Notion 親ページ: `NOTION_DASHBOARD_PAGE_ID`
- 生成物: パイプライン実行毎に `Deal Review Dashboard YYYY-MM-DD` ページを新規作成

## ガードレール

- ペルソナはローカルmdファイル（`~/claude-pipeline/skills/*.md`）から必ず読み込む
- 案件データの捏造禁止。Notion DBから取得したフィールドのみ参照
- 数値・固有名詞は出典フィールドを明記
- 各エージェントは前段アウトプットを入力に取り、独立に最終結論を述べる

## パイプライン実行手順

1. Notion MCPで `Pipeline Review` ビュー（`NOTION_PIPELINE_VIEW_ID`）を fetch（トリアージ済み案件のみ取得）
2. **Deal Triage** (`skills/deal-triage.md`): fetch 結果を確認・出力（Notion側でフィルタ済みのため追加処理不要）
3. Deal Strategist: 各案件のMEDDPICCスコアと verdict を生成（トリアージ通過案件のみ）
4. Pipeline Analyst: 3の結果＋トリアージ通過案件データから健全性・速度・予測を生成
5. Sales Coach: 3+4 の結果から担当者別コーチングプランを生成
6. ダッシュボードページを Notion に作成（3つのセクションを統合）
