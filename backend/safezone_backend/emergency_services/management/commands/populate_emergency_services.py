from django.core.management.base import BaseCommand
from emergency_services.models import EmergencyService


class Command(BaseCommand):
    help = 'Populate database with initial emergency services data for various countries'

    def handle(self, *args, **kwargs):
        self.stdout.write('Populating emergency services database...')
        
        # Clear existing data
        EmergencyService.objects.all().delete()
        
        services = [
            # United States
            EmergencyService(
                country_code='US',
                name='Emergency Services',
                service_type='police',
                phone_number='911',
                latitude=40.7580,
                longitude=-73.9855,
                address='Emergency Police Services',
                hours='24/7',
            ),
            EmergencyService(
                country_code='US',
                name='Emergency Medical Services',
                service_type='ambulance',
                phone_number='911',
                latitude=40.7614,
                longitude=-73.9776,
                address='Emergency Ambulance Services',
                hours='24/7',
            ),
            EmergencyService(
                country_code='US',
                name='Fire Department',
                service_type='fireStation',
                phone_number='911',
                latitude=40.7489,
                longitude=-73.9750,
                address='Emergency Fire Services',
                hours='24/7',
            ),
            EmergencyService(
                country_code='US',
                name='Hospital Emergency',
                service_type='hospital',
                phone_number='911',
                latitude=40.7692,
                longitude=-73.9547,
                address='Emergency Hospital Services',
                hours='24/7 Emergency',
            ),
            
            # United Kingdom
            EmergencyService(
                country_code='GB',
                name='Metropolitan Police Service',
                service_type='police',
                phone_number='999',
                latitude=51.5074,
                longitude=-0.1278,
                address='New Scotland Yard, London',
                hours='24/7',
            ),
            EmergencyService(
                country_code='GB',
                name='NHS Ambulance Service',
                service_type='ambulance',
                phone_number='999',
                latitude=51.5074,
                longitude=-0.1278,
                address='Emergency Ambulance Dispatch',
                hours='24/7',
            ),
            EmergencyService(
                country_code='GB',
                name='Fire and Rescue Service',
                service_type='fireStation',
                phone_number='999',
                latitude=51.5074,
                longitude=-0.1278,
                address='Fire Emergency Services',
                hours='24/7',
            ),
            EmergencyService(
                country_code='GB',
                name='NHS Emergency Services',
                service_type='hospital',
                phone_number='999',
                latitude=51.5074,
                longitude=-0.1278,
                address='Emergency Medical Services',
                hours='24/7 Emergency',
            ),
            
            # Ghana
            EmergencyService(
                country_code='GH',
                name='Ghana Police Service',
                service_type='police',
                phone_number='191',
                latitude=5.6037,
                longitude=-0.1870,
                address='Police Headquarters, Accra',
                hours='24/7',
            ),
            EmergencyService(
                country_code='GH',
                name='National Ambulance Service',
                service_type='ambulance',
                phone_number='193',
                latitude=5.6037,
                longitude=-0.1870,
                address='Emergency Ambulance Service',
                hours='24/7',
            ),
            EmergencyService(
                country_code='GH',
                name='Ghana National Fire Service',
                service_type='fireStation',
                phone_number='192',
                latitude=5.6037,
                longitude=-0.1870,
                address='Fire Service Headquarters, Accra',
                hours='24/7',
            ),
            EmergencyService(
                country_code='GH',
                name='Emergency Medical Services',
                service_type='hospital',
                phone_number='193',
                latitude=5.6037,
                longitude=-0.1870,
                address='National Ambulance Service',
                hours='24/7 Emergency',
            ),
            
            # Nigeria
            EmergencyService(
                country_code='NG',
                name='Nigeria Police Force',
                service_type='police',
                phone_number='112',
                latitude=9.0765,
                longitude=7.3986,
                address='Emergency Response',
                hours='24/7',
            ),
            EmergencyService(
                country_code='NG',
                name='Emergency Medical Services',
                service_type='ambulance',
                phone_number='112',
                latitude=9.0765,
                longitude=7.3986,
                address='National Emergency Number',
                hours='24/7',
            ),
            EmergencyService(
                country_code='NG',
                name='Fire Service',
                service_type='fireStation',
                phone_number='112',
                latitude=9.0765,
                longitude=7.3986,
                address='Emergency Fire Services',
                hours='24/7',
            ),
            EmergencyService(
                country_code='NG',
                name='Hospital Emergency',
                service_type='hospital',
                phone_number='112',
                latitude=9.0765,
                longitude=7.3986,
                address='Emergency Medical Response',
                hours='24/7 Emergency',
            ),
            
            # Kenya
            EmergencyService(
                country_code='KE',
                name='Kenya Police Service',
                service_type='police',
                phone_number='999',
                latitude=-1.2921,
                longitude=36.8219,
                address='Police Emergency Response',
                hours='24/7',
            ),
            EmergencyService(
                country_code='KE',
                name='Emergency Medical Services',
                service_type='ambulance',
                phone_number='999',
                latitude=-1.2921,
                longitude=36.8219,
                address='Ambulance Emergency Services',
                hours='24/7',
            ),
            EmergencyService(
                country_code='KE',
                name='Fire Department',
                service_type='fireStation',
                phone_number='999',
                latitude=-1.2921,
                longitude=36.8219,
                address='Fire Emergency Services',
                hours='24/7',
            ),
            EmergencyService(
                country_code='KE',
                name='Hospital Emergency',
                service_type='hospital',
                phone_number='999',
                latitude=-1.2921,
                longitude=36.8219,
                address='Emergency Medical Care',
                hours='24/7 Emergency',
            ),
        ]
        
        EmergencyService.objects.bulk_create(services)
        
        self.stdout.write(
            self.style.SUCCESS(
                f'Successfully created {len(services)} emergency service records'
            )
        )
