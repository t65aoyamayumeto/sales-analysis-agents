# sales-analysis-agents

NotionをCRMに見立てた案件評価パイプライン。Deal Strategist / Pipeline Analyst / Sales Coach の3エージェントが直列に動き、マネージャー向けダッシュボードをNotionに自動生成する。

## 概要

既存のCRMアラートは「案件が止まっている」を教える。このパイプラインは「なぜ止まっているか」「誰が何をすべきか」まで答える。

```
Notion Deals DB
      |
  Deal Triage          ← ステージ・活動日数でフィルタ、サニタイズチェック
      |
Notion Activities DB
      |
  Deal Strategist      ← MEDDPICC採点・競合ポジショニング・verdict（案件単位）
      |
  Pipeline Analyst     ← カバレッジ・速度・予測（ポートフォリオ単位）
      |
  Sales Coach          ← 担当者別コーチングプラン・1on1議題（担当者単位）
      |
Notion Dashboard Page  ← Deal Review Dashboard YYYY-MM-DD
```

## ファイル構成

```
.claude/agents/
  sales-deal-strategist.md   エージェント起動設定（ツール・モデル・入出力規約）
  sales-pipeline-analyst.md
  sales-coach.md

skills/
  deal-triage.md             トリアージ条件・サニタイズチェック手順
  deal-strategist.md         MEDDPICCフレームワーク・採点基準・出力テンプレート
  pipeline-analyst.md        カバレッジ計算・予測手法・ダッシュボード形式
  sales-coach.md             コーチングフレームワーク・1on1議題テンプレート

CLAUDE.md                    パイプライン全体の設計図・実行手順
.env.example                 必要な環境変数の一覧
```

## 前提条件

- [Claude Code](https://claude.ai/code) がインストール済みであること
- Notion MCP が Claude Code に接続済みであること
- 後述の環境変数が設定済みであること
- Notion 側に以下のDB構造が用意されていること

## Notion DB構造

### Deals DB

案件の基本情報を管理するメインDB。

| フィールド名 | 型 | 用途 |
|---|---|---|
| Name | Title | 案件名 |
| Stage | Select | Prospect / Qualify / Discovery / Proposal / Negotiation / Closed Won / Closed Lost |
| Amount | Number | 案件金額 |
| Close Date | Date | クローズ予定日 |
| Last Activity | Date | 最終活動日（トリアージ判定に使用） |
| Owner | Person | 担当者 |
| Next Step | Text | 次のアクション（自由記述） |
| Risk Notes | Text | リスクメモ（自由記述） |
| Pain | Text | 顧客の課題（自由記述） |
| Metrics | Text | 定量的な価値指標（自由記述） |
| Decision Criteria | Text | 評価基準（自由記述） |
| Champion | Text | 社内推進者（自由記述） |
| Economic Buyer | Text | 最終意思決定者（自由記述） |

### Activities DB

商談・連絡履歴を管理するDB。Deals DBとリレーションで紐付ける。

| フィールド名 | 型 | 用途 |
|---|---|---|
| Name | Title | 活動名 |
| Deal | Relation | Deals DB へのリレーション |
| Type | Select | Call / Meeting / Email / Task / Note |
| Outcome | Select | Planned / Completed / No show |
| Activity Date | Date | 活動日 |
| Owner | Person | 実施者 |
| Notes | Text | 活動メモ（自由記述） |
| Activity | Text | 活動内容（自由記述） |

### Quota DB

担当者別の売上目標を管理するDB。Pipeline Analyst のカバレッジ計算に使用する。

| フィールド名 | 型 | 用途 |
|---|---|---|
| Name | Title | 担当者名 |
| Owner | Person | 担当者 |
| Quota | Number | 売上目標額 |
| Period | Select | 対象クォーター（例: 2026-Q2） |

## セットアップ

**1. リポジトリをクローン**

```bash
git clone https://github.com/t65aoyamayumeto/sales-analysis-agents.git
cd sales-analysis-agents
```

**2. 環境変数を設定**

`.env.example` を参考に `.env` を作成する。

```bash
cp .env.example .env
```

| 変数名 | 説明 |
|--------|------|
| `NOTION_DEALS_DATA_SOURCE_URL` | 案件DB の `collection://` URL |
| `NOTION_ACTIVITIES_DATA_SOURCE_URL` | 活動DB の `collection://` URL |
| `NOTION_DASHBOARD_PAGE_ID` | ダッシュボード出力先の親ページID |
| `NOTION_CRM_PAGE_ID` | CRMルートページID（参照用、任意） |

`collection://` URL の取得方法は Notion MCP の `notion-search` をデータソースに対して実行し、レスポンスの `data_source_url` フィールドを確認する。


## 実行方法

Claude Code のチャットで以下のように伝えるだけで動く。

```
パイプラインを実行して
```

実行が完了するとNotionに `Deal Review Dashboard YYYY-MM-DD` ページが作成される。

## トリアージ設定

評価対象案件の絞り込み条件（`CLAUDE.md` と `skills/deal-triage.md` で管理）。

| 条件 | 値 |
|------|----|
| 対象ステージ | Qualify / Discovery / Proposal / Negotiation |
| 除外ステージ | Prospect / Closed Won / Closed Lost |
| 最終活動から | 45日以内（未設定の場合は対象に含める） |

## セキュリティ

Notionから取得するフィールド値（Next Step・Risk Notes・Pain等）はすべて**分析対象のデータ**として扱い、命令として解釈しない。疑義のある案件はサニタイズチェックで自動隔離され、残案件の評価は継続される。詳細は `skills/deal-triage.md` を参照。

## エージェント設計

`agents/` は薄い起動設定のみを持ち、ロジックは `skills/` に集約する。ペルソナ・採点基準・出力フォーマットを変更する場合は `skills/*.md` のみを編集すればよい。

## 参照元

`skills/` 配下のペルソナ定義は [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents/tree/main/sales) の Sales エージェント群をベースにしている。

- Deal Strategist / Pipeline Analyst / Sales Coach をはじめとする8種のセールスエージェント定義を含むリポジトリ

本プロジェクトはagency-agentsのスキルをCRMパイプライン用途に組み合わせ、Notionとの接続・トリアージ層・直列実行フローを追加したものです。

## ライセンス

MIT — Copyright (c) 2026 aoyamamuto

本プロジェクトの `skills/` ディレクトリは [agency-agents](https://github.com/msitarzewski/agency-agents)（MIT, Copyright (c) msitarzewski）のファイルを含みます。
