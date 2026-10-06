from django.urls import path
from . import views

urlpatterns = [
    path('',                    views.dashboard,        name='dashboard'),
    path('drivers/',            views.drivers,          name='drivers'),
    path('trips/',              views.trips,            name='trips'),
    path('demo/procedures/',    views.demo_procedures,  name='demo_procedures'),
    path('demo/triggers/',      views.demo_triggers,    name='demo_triggers'),
    path('demo/functions/',     views.demo_functions,   name='demo_functions'),
    path('demo/cursors/',       views.demo_cursors,     name='demo_cursors'),
    path('demo/security/',      views.demo_security,    name='demo_security'),
]
