#!/bin/sh
#
# Salve este script no diretório /etc/cron.hourly e dê permissão
# de execução a ele. Desse modo a cada hora sera verificada se a
# porcentagem de memória utilizada pelo sistema atingiu o valor definido
# na variável 'percent'. Caso positivo, o script informará ao kernel
# que este deverá alterar o valor da opção 'drop_caches' para 3.
#
# Mais detalhes: 'man proc' -> /proc/sys/vm/drop_caches.
PATH="/bin:/usr/bin:/usr/local/bin"

# Porcentagem máxima de uso da memória, antes de executar a limpeza:
# Obs.: Altere conforme sua necessidade.
percent=40

# Quantidade de memória RAM no sistema:
ramtotal=`grep -F "MemTotal:" < /proc/meminfo | awk '{print $2}'`
# Quantidade de RAM livre:
ramlivre=`grep -F "MemFree:" < /proc/meminfo | awk '{print $2}'`

# RAM utilizada pelo sistema:
ramusada=`expr $ramtotal - $ramlivre`

# Porcentagem de RAM utilizada pelo sistema:
putil=`expr $ramusada \* 100 / $ramtotal`

# Checando porcentagem:
if [ $putil -gt $percent ]
then
  # Sincronizando os dados cacheados na memória com o(s) disco(s):
  sync
  # 'Dropando' cache:
  echo 3 > /proc/sys/vm/drop_caches
else
  # Remove-se as variáveis da memória e finaliza-se o script:
  unset percent ramtotal ramlivre ramusada putil
  exit $?
fi # Fim