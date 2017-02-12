# passer sur branche master ou stable github
cd /home/vincent/jeux/mff/

# Suppression des anciens fichiers
rm -Rv /home/vincent/jeux/upgrade-mff/olds
rm -Rv /home/vincent/jeux/upgrade-mff/mff.tar.gz

# Sauvegarde des fichiers critiques
cp -Rv /home/vincent/jeux/mff/games/minetestforfun_game/ /home/vincent/jeux/upgrade-mff/olds/
cp -Rv /home/vincent/jeux/mff/mods/ /home/vincent/jeux/upgrade-mff/olds/
cp -Rv /home/vincent/jeux/mff/worlds/ /home/vincent/jeux/upgrade-mff/olds/
cp /home/vincent/jeux/mff/minetest.conf /home/vincent/jeux/upgrade-mff/olds/

# Sauvegarde et compression du dossier minetest (au cas ou)
cd /home/vincent/jeux/upgrade-mff/
tar -cf mff.tar.gz /home/vincent/jeux/mff/

# Suppression de minetest
rm -Rv /home/vincent/jeux/mff/

# Réinstallaton de minetest
cd /home/vincent/jeux/
# DEBUT - Utilisation de la dernière version 0.4 stable
wget https://codeload.github.com/minetest/minetest/zip/stable-0.4
unzip /home/vincent/jeux/stable-0.4
mv /home/vincent/jeux/minetest-stable-0.4/ /home/vincent/jeux/mff/
rm -v /home/vincent/jeux/stable-0.4
# FIN - Utilisation de la version 0.4 stable

# Compilation
cd /home/vincent/jeux/mff/
# Build REDIS + IRC
cmake . -DBUILD_CLIENT=0 -DBUILD_SERVER=1 -DENABLE_SOUND=0 -DENABLE_SYSTEM_GMP=1 -DIRRLICHT_SOURCE_DIR=/home/vincent/jeux/lib/irrlicht-1.8.4 -DENABLE_LEVELDB=0 -DENABLE_REDIS=1 -DRUN_IN_PLACE=1 -DENABLE_GETTEXT=1 -DENABLE_FREETYPE=1 -DENABLE_LUAJIT=1 -DENABLE_CURL=1
make -j$(grep -c processor /proc/cpuinfo)

# Ajout des fichiers critiques au nouveau dossier minetest
cp -Rv /home/vincent/jeux/upgrade-mff/olds/minetestforfun_game/ /home/vincent/jeux/mff/games/
cp -Rv /home/vincent/jeux/upgrade-mff/olds/mods/ /home/vincent/jeux/mff/
cp -Rv /home/vincent/jeux/upgrade-mff/olds/worlds/ /home/vincent/jeux/mff/
cp /home/vincent/jeux/upgrade-mff/olds/minetest.conf /home/vincent/jeux/mff/

## Donne les droits à quentinbd
#chmod -R 755 /home/quentinbd/mff/
#chown -R quentinbd:quentinbd /home/quentinbd/
