import compas
import random

from compas.datastructures import Mesh
from compas.numerical import dr_numpy

from compas.utilities import i_to_rgb

from compas_plotters import MeshPlotter



dva = {
    'is_fixed': False,
    'x': 0.0,
    'y': 0.0,
    'z': 0.0,
    'px': 0.0,  # x component of point load at vertices
    'py': 0.0,  # y component of point load at vertices
    'pz': 0.0,  # z component of point load at vertices
    'rx': 0.0,
    'ry': 0.0,
    'rz': 0.0,
}

dea = {
    'qpre': 1.0,  # prescribed force densities
    'fpre': 0.0,  # prescribed edge forces
    'lpre': 0.0,  # prescribed edge lengths
    'linit': 0.0,  # initial edge length
    'E': 0.0,  # initial edge length
    'radius': 0.0, # global initial cable radius
}


# create mesh object
mesh = Mesh.from_obj(compas.get('faces.obj'))


# update attributes
mesh.update_default_vertex_attributes(dva)
mesh.update_default_edge_attributes(dea)

# fix vertices
for key, attr in mesh.vertices(True):
    attr['is_fixed'] = mesh.vertex_degree(key) == 2

# randomize force densities at edges
# for u, v, attr in mesh.edges(True):
    # attr['qpre'] = 1.0 * random.randint(1, 7)
#   attr['qpre'] = 1.0 


# query attributes
k_i = mesh.key_index()
vertices = mesh.get_vertices_attributes(('x', 'y', 'z'))
edges = [(k_i[u], k_i[v]) for u, v in mesh.edges()]
fixed = [k_i[key] for key in mesh.vertices_where({'is_fixed': True})]
loads = mesh.get_vertices_attributes(('px', 'py', 'pz'))
qpre = mesh.get_edges_attribute('qpre')
fpre = mesh.get_edges_attribute('fpre')
lpre = mesh.get_edges_attribute('lpre')
linit = mesh.get_edges_attribute('linit')
E = mesh.get_edges_attribute('E')
radius = mesh.get_edges_attribute('radius')


# visualization - part A
# lines
lines = []
for u, v in mesh.edges():
    lines.append({
        'start': mesh.vertex_coordinates(u, 'xy'),
        'end': mesh.vertex_coordinates(v, 'xy'),
        'color': '#cccccc',
        'width': 0.5
    })


# create plotter
plotter = MeshPlotter(mesh, figsize=(10, 7), fontsize=6)


# plot first time
plotter.draw_lines(lines)
plotter.draw_vertices(facecolor={key: '#000000' for key in mesh.vertices_where({'is_fixed': True})})
plotter.draw_edges()
plotter.update(pause=1.0)


# define callback function
def callback(k, xyz, crits, args):
    # update plotter
    plotter.update_vertices()
    plotter.update_edges()
    plotter.update(pause=0.01)  # 0.001

    # update mesh vertex coordinates
    for key, attr in mesh.vertices(True):
        index = k_i[key]
        attr['x'] = xyz[index, 0]
        attr['y'] = xyz[index, 1]
        attr['z'] = xyz[index, 2]


# carry out dynamic relaxation with numpy
xyz, q, f, l, r = dr_numpy(vertices,
                           edges,
                           fixed,
                           loads,
                           qpre,
                           fpre,
                           lpre,
                           linit,
                           E,
                           radius,
                           kmax=100,
                           callback=callback
                           )


# update edges' force and length attributes 
for index, (u, v, attr) in enumerate(mesh.edges(True)):
    attr['f'] = f[index, 0]
    attr['l'] = l[index, 0]


# visualization - part B
# clear out canvas
plotter.clear_vertices()
plotter.clear_edges()


# draw vertices, supports with red
plotter.draw_vertices(
    facecolor={key: '#000000' for key in mesh.vertices_where({'is_fixed': True})}
)

# draw edges, colormap based on force f
fmax = max(mesh.get_edges_attribute('f'))
plotter.draw_edges(
    text={(u, v): '{:.2f}'.format(attr['f']) for u, v, attr in mesh.edges(True)},
    color={(u, v): i_to_rgb(attr['f'] / fmax) for u, v, attr in mesh.edges(True)},
    width={(u, v): 10 * attr['f'] / fmax for u, v, attr in mesh.edges(True)}
)

# update and show
plotter.update(pause=1.0)
plotter.show()
