#######################################################
# Cluster Talos
#######################################################
cluster_name = "talos-infrastructure"
control_plane_count = 1

#######################################################
# Workers de INFRAESTRUCTURA
#######################################################
infra_worker_count = 3
infra_node_prefix = "talos-infrastructure"

#######################################################
# Workers de APLICACIÓN
#######################################################
app_worker_count = 2
app_node_prefix = "talos-application"

#######################################################
# Gitea Configuration
#######################################################
gitea_runners = "gitea-runners"
gitea_count_runners = 0

