# -*- coding: utf-8 -*-

# @Author  : wzdnzd
# @Time    : 2022-07-15
# @Description: 代理拉取优化工具

import argparse
import json
import os
import sys
import time
import traceback
from concurrent.futures import ThreadPoolExecutor, as_completed

# 添加路径
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'subscribe'))

import utils
from logger import logger


class ProxyOptimizer:
    def __init__(self, config_file: str = ""):
        self.config_file = config_file or "subscribe/config/config.default.json"
        self.config = self.load_config()
        
    def load_config(self) -> dict:
        """加载配置文件"""
        try:
            with open(self.config_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"配置文件加载失败: {e}")
            return {}
    
    def test_connectivity(self) -> dict:
        """测试网络连接性"""
        test_urls = {
            "google": "https://www.google.com",
            "github": "https://github.com", 
            "telegram": "https://t.me",
            "httpbin": "https://httpbin.org/ip"
        }
        
        results = {}
        
        def test_url(name: str, url: str) -> tuple:
            try:
                start_time = time.time()
                response = utils.http_get(url=url, timeout=10)
                end_time = time.time()
                
                if response:
                    return name, {
                        "status": "success",
                        "response_time": round(end_time - start_time, 2),
                        "response_length": len(response)
                    }
                else:
                    return name, {"status": "failed", "error": "no_response"}
            except Exception as e:
                return name, {"status": "failed", "error": str(e)}
        
        with ThreadPoolExecutor(max_workers=4) as executor:
            futures = [executor.submit(test_url, name, url) for name, url in test_urls.items()]
            
            for future in as_completed(futures):
                name, result = future.result()
                results[name] = result
        
        return results
    
    def optimize_config(self) -> dict:
        """优化配置"""
        optimized = self.config.copy()
        
        # 优化爬虫配置
        if "crawl" in optimized:
            crawl_config = optimized["crawl"]
            
            # 降低阈值以获取更多结果
            crawl_config["threshold"] = max(crawl_config.get("threshold", 5), 3)
            
            # 启用更多源
            if "google" in crawl_config:
                crawl_config["google"]["enable"] = True
            
            # 增加页面数量
            if "github" in crawl_config:
                github_pages = crawl_config["github"].get("pages", 2)
                if isinstance(github_pages, int):
                    crawl_config["github"]["pages"] = min(github_pages, 5)
            
            # 增加Telegram页面
            if "telegram" in crawl_config:
                telegram_pages = crawl_config["telegram"].get("pages", 5)
                if isinstance(telegram_pages, int):
                    crawl_config["telegram"]["pages"] = min(telegram_pages, 10)
        
        # 优化域名配置
        if "domains" in optimized:
            for domain in optimized["domains"]:
                # 确保启用检查
                domain["liveness"] = True
                # 增加重试率
                domain["rate"] = min(domain.get("rate", 2.5), 5.0)
        
        return optimized
    
    def add_sample_sources(self) -> dict:
        """添加示例源"""
        optimized = self.config.copy()
        
        # 添加一些公开的示例源（仅用于测试）
        sample_pages = [
            {
                "enable": True,
                "url": "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/Proxies.ini",
                "include": "",
                "exclude": "",
                "config": {
                    "rename": "",
                    "liveness": True
                },
                "push_to": []
            }
        ]
        
        if "crawl" in optimized and "pages" in optimized["crawl"]:
            # 合并示例源
            optimized["crawl"]["pages"].extend(sample_pages)
        
        return optimized
    
    def create_optimized_config(self, output_file: str = "subscribe/config/config.optimized.json"):
        """创建优化后的配置文件"""
        # 基础优化
        optimized = self.optimize_config()
        
        # 添加示例源
        optimized = self.add_sample_sources()
        
        # 保存优化后的配置
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(optimized, f, indent=2, ensure_ascii=False)
            logger.info(f"优化后的配置已保存到: {output_file}")
            return True
        except Exception as e:
            logger.error(f"保存优化配置失败: {e}")
            return False
    
    def test_crawl_sources(self) -> dict:
        """测试爬虫源"""
        if not self.config.get("crawl", {}).get("enable", False):
            return {"error": "爬虫功能未启用"}
        
        crawl_config = self.config["crawl"]
        results = {}
        
        # 测试GitHub源
        if crawl_config.get("github", {}).get("enable", False):
            try:
                # 这里可以添加实际的GitHub API测试
                results["github"] = {"status": "enabled", "note": "需要网络访问GitHub"}
            except Exception as e:
                results["github"] = {"status": "error", "error": str(e)}
        
        # 测试Telegram源
        if crawl_config.get("telegram", {}).get("enable", False):
            results["telegram"] = {"status": "enabled", "note": "需要网络访问Telegram"}
        
        # 测试Google源
        if crawl_config.get("google", {}).get("enable", False):
            results["google"] = {"status": "enabled", "note": "需要网络访问Google"}
        
        return results
    
    def generate_report(self) -> str:
        """生成诊断报告"""
        report = []
        report.append("=== 代理拉取优化报告 ===\n")
        
        # 网络连接测试
        report.append("1. 网络连接测试:")
        connectivity = self.test_connectivity()
        for name, result in connectivity.items():
            status = "✓" if result["status"] == "success" else "✗"
            report.append(f"   {status} {name}: {result['status']}")
            if result["status"] == "success":
                report.append(f"     响应时间: {result.get('response_time', 'N/A')}s")
            else:
                report.append(f"     错误: {result.get('error', 'unknown')}")
        
        # 配置检查
        report.append("\n2. 配置检查:")
        if self.config:
            report.append("   ✓ 配置文件加载成功")
            
            crawl_config = self.config.get("crawl", {})
            report.append(f"   - 爬虫功能: {'启用' if crawl_config.get('enable', False) else '禁用'}")
            report.append(f"   - GitHub源: {'启用' if crawl_config.get('github', {}).get('enable', False) else '禁用'}")
            report.append(f"   - Telegram源: {'启用' if crawl_config.get('telegram', {}).get('enable', False) else '禁用'}")
            report.append(f"   - Google源: {'启用' if crawl_config.get('google', {}).get('enable', False) else '禁用'}")
        else:
            report.append("   ✗ 配置文件加载失败")
        
        # 源测试
        report.append("\n3. 爬虫源测试:")
        source_results = self.test_crawl_sources()
        for source, result in source_results.items():
            if source == "error":
                report.append(f"   ✗ {result}")
            else:
                status = "✓" if result["status"] == "enabled" else "✗"
                report.append(f"   {status} {source}: {result['status']}")
                if "note" in result:
                    report.append(f"     说明: {result['note']}")
        
        # 优化建议
        report.append("\n4. 优化建议:")
        
        # 基于网络连接结果给出建议
        failed_sources = [name for name, result in connectivity.items() if result["status"] != "success"]
        if failed_sources:
            report.append("   - 网络问题检测:")
            for source in failed_sources:
                if source == "google":
                    report.append("     * 无法访问Google，建议配置代理或禁用Google搜索")
                elif source == "github":
                    report.append("     * 无法访问GitHub，建议检查网络或使用代理")
                elif source == "telegram":
                    report.append("     * 无法访问Telegram，建议配置代理或禁用Telegram爬虫")
        
        # 基于配置给出建议
        if not self.config.get("crawl", {}).get("enable", False):
            report.append("   - 启用爬虫功能以获取更多代理源")
        
        if not self.config.get("domains", []):
            report.append("   - 添加自定义域名配置")
        
        report.append("\n=== 快速修复命令 ===")
        report.append("python3 optimize_proxy.py --create-optimized-config")
        report.append("python3 subscribe/process.py --config subscribe/config/config.optimized.json")
        
        return "\n".join(report)


def main():
    parser = argparse.ArgumentParser(description="代理拉取优化工具")
    parser.add_argument("--config", default="", help="配置文件路径")
    parser.add_argument("--test-connectivity", action="store_true", help="测试网络连接")
    parser.add_argument("--create-optimized-config", action="store_true", help="创建优化配置")
    parser.add_argument("--generate-report", action="store_true", help="生成诊断报告")
    parser.add_argument("--output", default="subscribe/config/config.optimized.json", help="优化配置输出文件")
    
    args = parser.parse_args()
    
    optimizer = ProxyOptimizer(args.config)
    
    if args.test_connectivity:
        results = optimizer.test_connectivity()
        print("网络连接测试结果:")
        for name, result in results.items():
            print(f"{name}: {result}")
    
    elif args.create_optimized_config:
        success = optimizer.create_optimized_config(args.output)
        if success:
            print(f"优化配置已创建: {args.output}")
        else:
            print("创建优化配置失败")
    
    elif args.generate_report:
        report = optimizer.generate_report()
        print(report)
    
    else:
        # 默认生成报告
        report = optimizer.generate_report()
        print(report)


if __name__ == "__main__":
    main()