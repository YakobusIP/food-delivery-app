from typing import Any
from django.core.management.base import BaseCommand
from faker import Faker
from ...models import Restaurant

class Command(BaseCommand):
    help = "Seed the database"

    def handle(self, *args: Any, **options: Any) -> str | None:
        faker = Faker()

        for _ in range(100):
            # Generate opening time
            opening_hour = faker.random_int(min=0, max=22)  # Up to 22 to leave room for closing time
            opening_minute = faker.random_int(min=0, max=59)
            opening_time = f"{opening_hour:02d}:{opening_minute:02d}"

            # Generate closing time by ensuring it's at least 1 hour after the opening
            closing_hour = faker.random_int(min=opening_hour + 1, max=23)
            closing_minute = faker.random_int(min=0, max=59)
            closing_time = f"{closing_hour:02d}:{closing_minute:02d}"

            image_urls = [
                "https://firebasestorage.googleapis.com/v0/b/bnmo-projects.appspot.com/o/door_dash%2Fhokben.png?alt=media&token=2a065809-30a7-44f2-93fe-c516727955c6",
                "https://firebasestorage.googleapis.com/v0/b/bnmo-projects.appspot.com/o/door_dash%2Fkfc.png?alt=media&token=afed4069-060c-43fe-9994-a2d484e329a7",
                "https://firebasestorage.googleapis.com/v0/b/bnmo-projects.appspot.com/o/door_dash%2Fmcdonalds.png?alt=media&token=b83adc17-aae5-495f-8c9c-d87d8f134eda"
            ]

            owner_ids = [2, 3, 13]

            Restaurant.objects.create(
                name=faker.name(),
                address=faker.address(),
                phone_number=faker.unique.phone_number(),
                email=faker.unique.email(),
                rating=faker.random_int(min=0, max=50) / 10.0,
                delivery_radius=faker.random_int(min=1, max=10),
                opening_time=opening_time,
                closing_time=closing_time,
                image_path=faker.random_element(image_urls)
            )
        
        self.stdout.write(self.style.SUCCESS("Database seed successful"))