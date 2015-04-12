KxSMBのサンプルを元に作成した。
https://github.com/kolyvan/kxsmb.git

Rakefileの中でcurlコマンドを実行している箇所で
ダウンロードしたtar.gzファイルが壊れていてエラーが出たので該当箇所はコメントアウトしている。
下記URLからダウンロードしてプロジェクトのルートディレクトリに格納する。
https://ftp.samba.org/pub/samba/stable/samba-4.0.21.tar.gz

プロジェクトのルートに移動し、rakeコマンドを実行する。
cd kxsmb
rake
