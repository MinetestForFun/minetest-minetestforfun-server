# On récupère la dernière version du jeu
cd /home/vincent/jeux
git clone -b sys4 https://github.com/sys4-fr/server-minetestforfun.git
echo "Clone de server-minetestforfun réussit."
cd /home/vincent/jeux/server-minetestforfun/
git submodule update --init --recursive

# On sauvegarde les anciens ../games et ../mods
rm -R /home/vincent/jeux/upgrade-mff/olds-part/games/
rm -R /home/vincent/jeux/upgrade-mff/olds-part/mods/
echo "Ancienne sauvegarde de /mods et /games correctement supprimée."

cp -R /home/vincent/jeux/mff/mods/ /home/vincent/jeux/upgrade-mff/olds-part/
cp -R /home/vincent/jeux/mff/games/ /home/vincent/jeux/upgrade-mff/olds-part/
echo "Sauvegarde de /mods et /games correctement effectuée."

# On MAJ les nouveaux minetest/games et minetest/mods
rm -R /home/vincent/jeux/mff/games/
rm -R /home/vincent/jeux/mff/mods/
mkdir -p /home/vincent/jeux/mff/games/
cp -R /home/vincent/jeux/server-minetestforfun/minetestforfun_game/ /home/vincent/jeux/mff/games/
cp -R /home/vincent/jeux/server-minetestforfun/mods/ /home/vincent/jeux/mff/
echo "Nouveaux /mods et /games correctement déplacés"

# On MAJ le minetest.conf, world.mt, random_messages, forbidden_names, et le news.txt
mkdir -p /home/vincent/jeux/mff/worlds/minetestforfun/
rm /home/vincent/jeux/mff/minetest.conf
rm /home/vincent/jeux/mff/worlds/minetestforfun/world.mt
rm /home/vincent/jeux/mff/worlds/minetestforfun/random_messages
rm /home/vincent/jeux/mff/worlds/minetestforfun/news.txt
rm /home/vincent/jeux/mff/worlds/minetestforfun/forbidden_names.txt
# On les remet
cp /home/vincent/jeux/server-minetestforfun/minetest.conf /home/vincent/jeux/mff/
cp /home/vincent/jeux/server-minetestforfun/worlds/minetestforfun/world.mt /home/vincent/jeux/mff/worlds/minetestforfun/
cp /home/vincent/jeux/server-minetestforfun/worlds/minetestforfun/random_messages /home/vincent/jeux/mff/worlds/minetestforfun/
cp /home/vincent/jeux/server-minetestforfun/worlds/minetestforfun/news.txt /home/vincent/jeux/mff/worlds/minetestforfun/
cp /home/vincent/jeux/server-minetestforfun/worlds/minetestforfun/forbidden_names.txt /home/vincent/jeux/mff/worlds/minetestforfun/
echo "Nouvelles news.txt, world.mt  et random_messages correctement déplacé"

# TEMPORAIRE - ré-ajout de l'ancien mod irc
#rm -R /home/quentinbd/mff/mods/irc/
#cp -R /home/quentinbd/server-minetestforfun/other_things/irc-old-save/ /home/quentinbd/mff/mods/
#mv /home/quentinbd/mff/mods/irc-old-save/ /home/quentinbd/mff/mods/irc/
#echo "TEMPORAIRE - ré-ajout de l'ancien mod irc"

# Suppression du dossier cloné
rm -Rf /home/vincent/jeux/server-minetestforfun/
echo "Bravo ! mff/mods et mff/games maintenant à jour"

# On ré-attribut les droits à quentinbd et en 755
#chown -R quentinbd:quentinbd /home/quentinbd/mff/
#chmod -R 755 /home/quentinbd/mff/
#echo "ré-attribution des droits à quentinbd:quentinbd"
