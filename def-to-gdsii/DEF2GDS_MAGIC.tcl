    box 0 0 0 0
    drc off
    snap int
    lef read XXX_tech.lef
 
    gds readonly true
    gds rescale false
    gds read XXX_base_lvt.gds2
    gds read XXX_base_hvt.gds2
    gds read XXX_base_rvt.gds2

    load bsg_manycore_tile
    def read bsg_manycore_tile

    select top cell
    expand
    gds write bsg_manycore_tile
    quit -noprompt
