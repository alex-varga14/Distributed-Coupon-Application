"""backendapp URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import include, path
from backendcore import views

urlpatterns = [
    path('placeholder/', views.PlaceholderAPIView.as_view()),

    # https://www.django-rest-framework.org/api-guide/filtering/
    path('placeholder1/<str:query>/', views.Placeholder1APIView.as_view()),

    path('coupons/', views.CouponsAPIView.as_view()),
    path('vendors/', views.VendorsAPIView.as_view()),

    path('proc/leader/', views.ProcLeaderAPIView.as_view()),
    path('proc/leader/<str:pid>/', views.ProcLeaderReqAPIView.as_view()),

    path('admin/', admin.site.urls),

    #sync
    path('', views.AliveAPIView.as_view()),
    path('coupons/acquire/<int:id>/', views.CouponAcquireAPIView.as_view()),
    path('coupons/release/<int:id>/', views.CouponReleaseAPIView.as_view()),
]
