use `sesssion4_qlct`;

ALTER TABLE building
    ADD CONSTRAINT fk_building_host
        FOREIGN KEY (host_id) REFERENCES host(id),
    ADD CONSTRAINT fk_building_contractor
        FOREIGN KEY (contractor_id) REFERENCES contractor(id);

ALTER TABLE design
    ADD CONSTRAINT fk_design_building
        FOREIGN KEY (building_id) REFERENCES building(id),
    ADD CONSTRAINT fk_design_architect
        FOREIGN KEY (architect_id) REFERENCES architect(id);

ALTER TABLE work
    ADD CONSTRAINT fk_work_building
        FOREIGN KEY (building_id) REFERENCES building(id),
    ADD CONSTRAINT fk_work_worker
        FOREIGN KEY (worker_id) REFERENCES worker(id);

-- EX3
select * 
from building
where cost = (select max(cost) from building);

select * 
from building
where cost > all (
    select cost 
    from building 
    where city = 'Cần Thơ'
);

select * 
from building
where cost > any (
    select cost 
    from building 
    where city = 'Cần Thơ'
);

select * 
from building 
where id not in (
    select building_id 
    from design
);

select * 
from architect a1
where exists (
    select 1 
    from architect a2 
    where a1.id != a2.id 
    and a1.birthday = a2.birthday 
    and a1.place = a2.place
);

-- Ex4
-- 1. Hiển thị thù lao trung bình của từng kiến trúc sư
select architect_id, avg(benefit) as avg_benefit
from design
group by architect_id;

-- 2. Hiển thị chi phí đầu tư cho các công trình ở mỗi thành phố
select city, sum(cost) as total_investment
from building
group by city;

-- 3. Tìm các công trình có chi phí trả cho kiến trúc sư lớn hơn 50
select *
from design
where benefit > 50;

-- 4. Tìm các thành phố có ít nhất một kiến trúc sư tốt nghiệp
select distinct b.city
from building b
join design d on b.id = d.building_id
join architect a on d.architect_id = a.id
where a.place is not null;

-- Ex5
-- 1. Hiển thị tên công trình, tên chủ nhân và tên chủ thầu của công trình đó
select 
    b.name as building_name,
    h.name as host_name,
    c.name as contractor_name
from building b
inner join host h on b.host_id = h.id
inner join contractor c on b.contractor_id = c.id;

-- 2. Hiển thị tên công trình, tên kiến trúc sư và thù lao của kiến trúc sư ở mỗi công trình
select 
    b.name as building_name,
    a.name as architect_name,
    d.benefit as architect_benefit
from design d
inner join building b on d.building_id = b.id
inner join architect a on d.architect_id = a.id;

-- 3. Hiển thị tên và địa chỉ công trình do chủ thầu 'Công ty xây dựng số 6' thi công
select 
    b.name as building_name,
    b.address as building_address
from building b
inner join contractor c on b.contractor_id = c.id
where c.name = 'Công ty xây dựng số 6';

-- 4. Tìm tên và địa chỉ liên lạc của các chủ thầu thi công công trình ở Cần Thơ do kiến trúc sư Lê Kim Dung thiết kế
select 
    c.name as contractor_name,
    c.address as contractor_address
from building b
inner join contractor c on b.contractor_id = c.id
inner join design d on b.id = d.building_id
inner join architect a on d.architect_id = a.id
where b.city = 'Cần Thơ' and a.name = 'Lê Kim Dung';

-- 5.Hãy cho biết nơi tốt nghiệp của các kiến trúc sư (architect) đã thiết kế (design) công trình Khách Sạn Quốc Tế ở Cần Thơ (building)
select architect.name as architect_name, architect.place as graduation_place
from architect
join design on architect.id = design.architect_id
join building on design.building_id = building.id
where building.name = 'khách sạn quốc tế ở cần thơ';

-- 6.Cho biết họ tên, năm sinh, năm vào nghề của các công nhân có chuyên môn hàn hoặc điện (worker) đã tham gia các công trình (work) 
--  mà chủ thầu Lê Văn Sơn (contractor) đã trúng thầu (building)
select worker.name as worker_name, worker.birthday, worker.year
from worker
join work on worker.id = work.worker_id
join building on work.building_id = building.id
join contractor on building.contractor_id = contractor.id
where (worker.skill = 'hàn' or worker.skill = 'điện')
and contractor.name = 'lê văn sơn';

-- 7.Những công nhân nào (worker) đã bắt đầu tham gia công trình Khách sạn Quốc Tế ở Cần Thơ (building) trong 
-- giai đoạn từ ngày 15/12/1994 đến 31/12/1994 (work) số ngày tương ứng là bao nhiêu
select worker.name as worker_name, datediff(work.date, '1994-12-15') as days_worked
from worker
join work on worker.id = work.worker_id
join building on work.building_id = building.id
where building.name = 'khách sạn quốc tế ở cần thơ'
and work.date between '1994-12-15' and '1994-12-31';

-- 8.Cho biết họ tên và năm sinh của các kiến trúc sư đã tốt nghiệp ở TP Hồ Chí Minh (architect)
-- và đã thiết kế ít nhất một công trình (design) có kinh phí đầu tư trên 400 triệu đồng (building)
select architect.name as architect_name, architect.birthday
from architect
join design on architect.id = design.architect_id
join building on design.building_id = building.id
where architect.place = 'TP Hồ Chí Minh'
and building.cost > 400000000;

-- 9.Cho biết tên công trình có kinh phí cao nhất
select building.name as building_name
from building
order by building.cost desc
limit 1;

-- 10.Cho biết tên các kiến trúc sư (architect) vừa thiết kế các công trình (design) do Phòng dịch vụ sở xây dựng (contractor) 
-- thi công vừa thiết kế các công trình do chủ thầu Lê Văn Sơn thi công

select distinct architect.name as architect_name
from architect
join design on architect.id = design.architect_id
join building on design.building_id = building.id
join contractor on building.contractor_id = contractor.id
where contractor.name = 'Phòng dịch vụ sở xây dựng'
and building.id in (
    select building.id
    from building
    join contractor on building.contractor_id = contractor.id
    where contractor.name = 'Lê Văn Sơn'
);

-- 11.Cho biết họ tên các công nhân (worker) có tham gia (work) các công trình ở Cần Thơ (building) nhưng không có tham gia công trình ở Vĩnh Long
select distinct worker.name as worker_name
from worker
join work on worker.id = work.worker_id
join building on work.building_id = building.id
where building.city = 'Can Tho'
and worker_id not in(
	select worker_id
    from work
    join building on work.building_id = building.id
    where building.city= 'Vinh Long'
);

-- 12. Cho biết tên của các chủ thầu đã thi công các công trình có kinh phí lớn hơn tất cả các công trình do chủ thầu phòng Dịch vụ Sở xây dựng thi công
select distinct contractor.name as contractor_name
from contractor
join building on contractor.id = building.contractor_id
where building.cost  > all (
	select building.cost
    from building
    join contractor on building.contractor_id = contractor.id
    where contractor.name = 'phong dich vu so xd'
);

-- 13. Cho biết họ tên các kiến trúc sư có thù lao thiết kế một công trình nào đó dưới giá trị trung bình thù lao thiết kế cho một công trình
select distinct architect.name as architect_name
from architect
join design on architect.id = design.architect_id
join building on design.building_id = building.id
where design.benefit < (
    select avg(design.benefit) 
    from design
);
-- 14.Tìm tên và địa chỉ những chủ thầu đã trúng thầu công trình có kinh phí thấp nhất
select contractor.name, contractor.address
from contractor
join building on contractor.id = building.contractor_id
where building.cost = (
    select min(building.cost)
    from building
);

-- 15.Tìm họ tên và chuyên môn của các công nhân (worker) tham gia (work) các công trình do kiến trúc sư Le Thanh Tung thiet ke (architect) (design)
select worker.name, worker.skill
from worker
join work on worker.id = work.worker_id
join building on work.building_id = building.id
join design on building.id = design.building_id
join architect on architect_id = design.architect_id
where architect.name = 'le thanh tung';

-- 16.Tìm các cặp tên của chủ thầu có trúng thầu các công trình tại cùng một thành phố
select c1.name as contractor1, c2.name as contractor2, b1.city
from contractor c1
join building b1 on c1.id = b1.contractor_id
join contractor c2 on b1.contractor_id = c2.id
join building b2 on c2.id = b2.contractor_id
where b1.city = b2.city
and c1.id < c2.id;
-- 17.Tìm tổng kinh phí của tất cả các công trình theo từng chủ thầu
select contractor.name, sum(building.cost) as total_cost
from contractor
join building on contractor.id = building.contractor_id
group by contractor.name;
-- 18.Cho biết họ tên các kiến trúc sư có tổng thù lao thiết kế các công trình lớn hơn 25 triệu
select architect.name, sum(building.cost) as total_fee
from architect
join design on architect.id = design.architect_id
join building on design.building_id = building.id
group by architect.name
having sum(building.cost) > 25000000;

-- 19.Cho biết số lượng các kiến trúc sư có tổng thù lao thiết kế các công trình lớn hơn 25 triệu
select count(distinct architect.id) as architect_count
from architect
join design on architect.id = design.architect_id
join building on design.building_id = building.id
group by architect.name
having sum(building.cost) > 25000000;

-- 20.Tìm tổng số công nhân đã than gia ở mỗi công trình
select count(distinct architect.id) as architect_count
from architect
join design on architect.id = design.architect_id
join building on design.building_id = building.id
group by architect.name
having sum(building.cost) > 25000000;

-- 21. Tìm tên và địa chỉ công trình có tổng số công nhân tham gia nhiều nhất
select building.name as building_name, building.address, count(work.worker_id) as total_workers
from building
join work on building.id = work.building_id
group by building.name, building.address
order by total_workers desc
limit 1;

-- 22.Cho biêt tên các thành phố và kinh phí trung bình cho mỗi công trình của từng thành phố tương ứng
select building.city, avg(building.cost) as average_cost
from building
group by building.city;

--  23.Cho biết họ tên các công nhân có tổng số ngày tham gia vào các công trình lớn hơn tổng số ngày tham gia của công nhân Nguyễn Hồng Vân
select worker.name
from worker
join work on worker.id = work.worker_id
group by worker.id
having sum(work.date) > (
    select sum(work.date)
    from work
    join worker on work.worker_id = worker.id
    where worker.name = 'Nguyễn Hồng Vân'
);

-- 24.Cho biết tổng số công trình mà mỗi chủ thầu đã thi công tại mỗi thành phố
select contractor.name as contractor_name, building.city, count(building.id) as total_buildings
from contractor
join building on contractor.id = building.contractor_id
group by contractor.name, building.city;

-- 25.Cho biết họ tên công nhân có tham gia ở tất cả các công trình
select worker.name
from worker
join work on worker.id = work.worker_id
group by worker.id
having count(distinct work.building_id) = (select count(distinct id) from building);

-- EX6
create database ex6;
use ex6;
-- Tạo bảng nhân viên
create table employee (
    id int primary key,
    name varchar(100),
    age int,
    salary decimal(10, 2)
);

-- Tạo bảng bộ phận
create table department (
    id int primary key,
    name varchar(100) unique
);

-- Tạo bảng liên kết giữa nhân viên và bộ phận
create table employee_department (
    employee_id int,
    department_id int,
    foreign key (employee_id) references employee(id),
    foreign key (department_id) references department(id),
    primary key (employee_id, department_id)
);

-- Chèn dữ liệu mẫu vào bảng employee
insert into employee (id, name, age, salary) values
(1, 'Nguyen Van A', 30, 60000),
(2, 'Le Thi B', 28, 48000),
(3, 'Tran Van C', 35, 75000),
(4, 'Do Thi D', 26, 52000),
(5, 'Pham Van E', 40, 90000);

-- Chèn dữ liệu mẫu vào bảng department
insert into department (id, name) values
(1, 'Ke toan'),
(2, 'Nhan su'),
(3, 'Ky thuat'),
(4, 'Marketing');


insert into employee_department (employee_id, department_id) values
(1, 1), (1, 2),
(2, 1),
(3, 3), (3, 4),
(4, 2),
(5, 3), (5, 4);

-- a. Viết câu lệnh SQL để liệt kê tất cả các nhân viên trong bộ phận có tên là "Kế toán". Kết quả cần hiển thị mã nhân viên và tên nhân viên.
select e.id, e.name
from employee e
join employee_department ed on e.id = ed.employee_id
join department d on ed.department_id = d.id
where d.name = 'Ke toan';

-- b. Viết câu lệnh SQL để tìm các nhân viên có mức lương lớn hơn 50,000. Kết quả trả về cần bao gồm mã nhân viên, tên nhân viên và mức lương.
select id, name, salary
from employee
where salary > 50000;

-- c. Viết câu lệnh SQL để hiển thị tất cả các bộ phận và số lượng nhân viên trong từng bộ phận. Kết quả trả về cần bao gồm tên bộ phận và số lượng nhân viên.
select d.name as department_name, count(ed.employee_id) as total_employees
from department d
left join employee_department ed on d.id = ed.department_id
group by d.name;

-- d. Viết câu lệnh SQL để tìm ra các thành viên có mức lương cao nhất theo từng bộ phận. Kết quả trả về là một danh sách theo bất cứ thứ tự nào. 
-- Nếu có nhiều nhân viên bằng lương nhau nhưng cũng là mức lương cao nhất thì hiển thị tất cả những nhân viên đó ra.
select d.name as department_name, e.name as employee_name, e.salary
from department d
join employee_department ed on d.id = ed.department_id
join employee e on ed.employee_id = e.id
where e.salary = (
    select max(e2.salary)
    from employee_department ed2
    join employee e2 on ed2.employee_id = e2.id
    where ed2.department_id = d.id
);

-- e.Viết câu lệnh SQL để tìm các bộ phận có tổng mức lương của nhân viên vượt quá 100,000 (hoặc một mức tùy chọn khác). 
-- Kết quả trả về bao gồm tên bộ phận và tổng mức lương của bộ phận đó.
select d.name as department_name, sum(e.salary) as total_salary
from department d
join employee_department ed on d.id = ed.department_id
join employee e on ed.employee_id = e.id
group by d.name
having sum(e.salary) > 100000;

-- Viết câu lệnh SQL để liệt kê tất cả các nhân viên làm việc trong hơn 2 bộ phận khác nhau. Kết quả cần hiển thị mã nhân viên, 
-- tên nhân viên và số lượng bộ phận mà họ tham gia.
select e.id, e.name, count(ed.department_id) as total_departments
from employee e
join employee_department ed on e.id = ed.employee_id
group by e.id, e.name
having count(ed.department_id) > 2;
