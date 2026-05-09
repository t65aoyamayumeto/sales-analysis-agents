---
name: Deal Triage
description: Pre-evaluation filter that selects which deals from the Notion CRM warrant full agent evaluation. Reduces token consumption by excluding closed, stale, or out-of-scope deals before the 3-agent pipeline runs.
---

# Deal Triage

Notion DBから全案件を取得した後、以下の条件でエージェント評価対象を絞り込む。
条件はすべて AND 結合。除外条件が優先される。

## トリアージ条件

### 1. ステージフィルタ

**対象ステージ（include）**
- `Qualify`
- `Discovery`
- `Proposal`
- `Negotiation`

**除外ステージ（exclude）**
- `Prospect` — 情報が少なすぎてMEDDPICC評価不可
- `Closed Won` — 完了済み
- `Closed Lost` — 完了済み

### 2. 最終活動フィルタ

- `Last Activity` が本日から **45日以内** のもののみ対象
- 45日を超えて無音の案件はゾンビパイプラインとみなし除外
- `Last Activity` が未設定の場合は **対象に含める**（データ欠損として評価対象とする）

### 3. 除外なし条件（現時点）

- 案件金額（Amount）: フィルタなし
- クローズ予定日（Close Date）: フィルタなし

## 実行手順

1. Notion MCP で Deals DB の全レコードを取得
2. 除外ステージに該当する案件を除く
3. 対象ステージに含まれない案件を除く
4. `Last Activity` が45日超の案件を除く（未設定は通過）
5. 残った案件リストをトリアージ結果として出力

## 出力フォーマット

```markdown
## トリアージ結果

**評価対象: N件 / 全件数: M件**

| Deal Name | Stage | Amount | Last Activity | 経過日数 | 選定理由 |
|-----------|-------|--------|--------------|---------|---------|
| [案件名] | [Stage] | [金額] | [日付] | [N日] | 対象ステージ・活動あり |

**除外案件: X件**

| Deal Name | Stage | 除外理由 |
|-----------|-------|---------|
| [案件名] | [Stage] | [理由] |
```

## 設定値の変更方法

CLAUDE.md の `## トリアージ設定` セクションで一元管理する。
本ファイルの数値はそちらを正とする。
