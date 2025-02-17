setwd('C:/Users/deisy/Desktop/PhD/05_Courses_Evop/Wormland/Wormland/')

files = system('ls *Network.csv', intern = T)

# files = list.files(pattern="*Network.csv")

for ( i in 1:length(files)){
  name = gsub(pattern = '_Network.csv', 
              replacement = '',
              x = files[i])
  ### Filter the data in the loop
  x = read.csv(files[i])
  x = x[,c(1:3,5)]
  x$wTO_sign = ifelse(x$pval_sig< 0.05, x$wTO_sign, 0)
  assign(name, x)
}

require(wTO)
NetVis(Node.1 = USA10n$Node.1, Node.2 = USA10n$Node.2,
       wTO = USA10n$wTO_sign, pval = USA10n$pval_sig, 
       MakeGroups = 'louvain', cutoff = list(kind = "Threshold", value = 0.1))


require(igraph)
g <- graph_from_data_frame(USA10n)


TAX = read.csv('C:/Users/deisy/Desktop/PhD/05_Courses_Evop/Wormland/Wormland/EcoW-Tax-Tree.csv', sep = ';')
TAX

TAX_tmp1 = cbind.data.frame(Node.1 = TAX$Order, Node.2 = TAX$Family)
TAX_tmp2 = cbind.data.frame(Node.1 = TAX$Family, Node.2 = TAX$Genus)
TAX_tmp3 = cbind.data.frame(Node.1 = TAX$Genus, Node.2 = TAX$OTU)
color = colorRampPalette(c('blue', 'red', 'purple', 'green', 'orange'))(24)

TAX_tmp3$color = TAX_tmp2$color = TAX_tmp1$color = color[unclass(TAX_tmp1$Node.1)]
COLS = rbind.data.frame(cbind(Node.1 = TAX_tmp1$Node.1, color = TAX_tmp1$color),
cbind(Node.1 = TAX_tmp2$Node.1, color = TAX_tmp2$color),
cbind(Node.1 = TAX_tmp3$Node.1, color = TAX_tmp3$color),
cbind(Node.1 = TAX_tmp1$Node.2, color = TAX_tmp1$color),
cbind(Node.1 = TAX_tmp2$Node.2, color = TAX_tmp2$color),
cbind(Node.1 = TAX_tmp3$Node.2, color = TAX_tmp3$color))


TAX_nodes = cbind.data.frame(Node.1 = TAX$OTU, size = TAX$Sum)
Others = cbind(Node.1 = c(as.character(TAX$Order), as.character(TAX$Family), as.character(TAX$Genus)), size = 0) %>% unique()
TAX_nodes = rbind(TAX_nodes, Others)
TAX_nodes = plyr::join(TAX_nodes, COLS)
TAX_tree = rbind(TAX_tmp1, TAX_tmp2, TAX_tmp3)
TAX_nodes$size = as.numeric(TAX_nodes$size)

require(RColorBrewer)

g_tree = graph_from_data_frame(TAX_tree, directed = F, vertices =  TAX_nodes)
V(g_tree)$size = CoDiNA::normalize(V(g_tree)$size) * 5
E(g_tree)$width = 1
plot(g_tree, vertex.label = NA)


### Now color the nodes acording to the family / genus / etc