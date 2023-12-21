# ISUCON13 問題

## 当日に公開したマニュアルおよびアプリケーションについての説明

- [ISUCON13 当日マニュアル](/docs/cautionary_note.md)
- [ISUCON13 アプリケーションマニュアル](/docs/isupipe.md)


## ディレクトリ構成

```
.
+- bech           # ベンチマーカー
+- development    # 開発環境用 docker compose
+- docs           # ドキュメント類
+- envcheck       # EC2サーバー 環境確認用プログラム
+- frontend       # フロントエンド
+- provisioning   # Ansible および Packer
+- scripts        # 初期、ベンチマーカー用データ生成用スクリプト
+- validated      # 競技後、最終チェックに用いたデータ
+- webapp         # 参考実装
```

## ISUCON13 予選当日との変更点

### Node.JSへのパッチ

当日、アプリケーションマニュアルにて公開した Node.JSへのパッチは適用済みです。[#408](https://github.com/isucon/isucon13/pull/408)

## TLS証明書について

ISUCON13で使用したTLS証明書は `provisioning/ansible/roles/nginx/files/etc/nginx/tls` 以下にあります。

本証明書は有効期限が切れている可能性があります。定期的な更新については予定しておりません。

## ISUCON13のインスタンスタイプ

- 競技者 VM 3台
  - InstanceType: c5.large (2vCPU, 4GiB Mem)
  - VolumeType: gp3 40GB
- ベンチマーカー VM 1台
  - ECS Fargate (8vCPU, 8GB Mem)

## docker compose での構築方法

開発に利用した docker composeで環境を構築することもできます。ただし、スペックやTLS証明書の有無など競技環境とは異なります。 アプリケーションは rust で起動します

```sh
$ cd development
$ make build # to build image
$ make up
$ make down
```

## ベンチマーカーの実行

docker composeの場合、ホストとなるマシン上でベンチマーカーをビルドする必要があります。

```sh
$ cd bench
$ make build # to build the program
$ make bench # to run

# OR at PROJECT ROOT DIR
$ make bench # to restart all system and clear metrics, and start bench
```

オプション

- `--nameserver`　は、ベンチマーカーが名前解決を行うサーバーのIPアドレスを指定して下さい
- `--webapp` は、名前解決を行うDNSサーバーが名前解決の結果返却する可能性があるIPアドレスを指定して下さい
  - 1台のサーバーで競技を行う場合は指定不要です
  - 複数台で競技を行う場合は、`--nameserver` に指定したアドレスを除いた、競技に使用するサーバーのIPアドレスを指定してください
- `--pretest-only` を付加することで、初期化処理と整合性チェックのみを行うことができます。アプリケーションの動作確認に利用してください。

`make bench-help` to see more.

## フロントエンドおよび動画配信について

フロントエンドの実装はリポジトリに存在していますが、競技の際に利用した動画とサムネイルについては配信サーバを廃止しており、表示できません。

## スコア履歴

タグを見る。

ベンチ環境

```
Linux 5.19.0-43-generic
Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
Mem 8GB
```

## Links

- [ISUCON13 まとめ](https://isucon.net/archives/57801192.html)

